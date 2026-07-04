/// Common app-wide Riverpod providers using code generation.
library;

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rug/services/network/dio_client.dart';
import 'package:rug/services/network/network_info.dart';
import 'package:rug/services/storage/local_storage_service.dart';
import 'package:rug/services/storage/secure_storage_service.dart';

part 'common_providers.g.dart';

/// Dio HTTP client provider.
@riverpod
Dio dio(Ref ref) => DioClient.instance;

/// Network connectivity info provider.
@riverpod
NetworkInfo networkInfo(Ref ref) => NetworkInfo();

/// Local storage (Hive) provider.
@riverpod
LocalStorageService localStorage(Ref ref) => LocalStorageService.instance;

/// Secure storage (tokens) provider.
@riverpod
SecureStorageService secureStorage(Ref ref) => SecureStorageService.instance;

/// Whether the user is currently authenticated.
@riverpod
class IsAuthenticated extends _$IsAuthenticated {
  @override
  bool build() => false;

  /// Update authentication status.
  void setAuthenticated(bool value) => state = value;
}

/// Current user ID (null when not logged in).
@riverpod
class CurrentUserId extends _$CurrentUserId {
  @override
  String? build() => null;

  /// Update the current user ID.
  void setUserId(String? value) => state = value;
}

/// Network connectivity status.
@riverpod
Future<bool> isOnline(Ref ref) async {
  final info = ref.watch(networkInfoProvider);
  return info.isConnected;
}
