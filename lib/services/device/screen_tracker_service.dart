import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rug/core/constants/api_constants.dart';
import 'package:rug/services/logging/app_logger.dart';
import 'package:rug/services/network/dio_client.dart';

/// Service for posting current screen information to the backend server.
class ScreenTrackerService {
  ScreenTrackerService._();

  /// Singleton instance of the service.
  static final ScreenTrackerService instance = ScreenTrackerService._();

  Dio get _dio => _customDio ?? DioClient.instance;
  Dio? _customDio;

  /// Injects a custom Dio client for unit testing.
  @visibleForTesting
  set dio(Dio value) => _customDio = value;

  /// Submits screen tracking information to the backend server.
  ///
  /// Takes a [screenName] (e.g. 'home_screen') and an optional [userId].
  /// If [userId] is null or cannot be parsed to an integer, it defaults to 0.
  Future<void> trackScreen(String screenName, {String? userId}) async {
    try {
      final parsedUserId = int.tryParse(userId ?? '') ?? 0;
      final payload = {
        'user_id': parsedUserId,
        'screen_name': screenName,
        'screen_time': DateTime.now().toUtc().toIso8601String(),
      };

      AppLogger.info('Tracking screen view: $screenName (user_id: $parsedUserId)');
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
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('success')) {
          isSuccess = responseData['success'] == true;
        }
      }

      if (isSuccess) {
        AppLogger.info('Screen info saved successfully: $screenName');
      } else {
        AppLogger.warning(
          'Failed to save screen info. Status code: ${response.statusCode}, response: $responseData',
        );
      }
    } catch (e) {
      AppLogger.error('Error tracking screen view: $screenName', error: e);
    }
  }
}
