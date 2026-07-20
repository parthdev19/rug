/// Low-level API layer for the screen-info endpoint.
///
/// Responsible only for making the HTTP call and returning raw data.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/features/screen_tracking/models/screen_info_model.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/network/dio_client.dart';

class ScreenInfoApi {
  ScreenInfoApi._();

  static final ScreenInfoApi instance = ScreenInfoApi._();

  Dio get _dio => _testDio ?? DioClient.instance;
  Dio? _testDio;

  /// Allows injecting a custom [Dio] instance during tests.
  @visibleForTesting
  set dio(Dio value) => _testDio = value;

  /// POST /v1/app/auth/screen-info
  ///
  /// Returns `true` on success, `false` on any non-fatal failure.
  Future<bool> postScreenInfo({
    required int userId,
    required ScreenInfoModel entry,
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'userId': userId,
        'screen_info': [entry.toJson()],
      };

      AppLogger.debug('Screen info payload: $payload');

      final response = await _dio.post(
        ApiConstants.screenInfo,
        data: payload,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      bool isSuccess = response.statusCode == 200 || response.statusCode == 201;
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('success')) {
        isSuccess = responseData['success'] == true;
      }

      return isSuccess;
    } on DioException catch (e) {
      AppLogger.warning('Screen info API error: ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Unexpected error posting screen info', error: e);
      return false;
    }
  }
}
