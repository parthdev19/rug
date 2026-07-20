/// Repository layer for screen info — bridges the API and the service.
///
/// Responsible for business logic such as resolving the user ID before
/// delegating to [ScreenInfoApi].
library;

import 'package:rug/features/screen_tracking/api/screen_info_api.dart';
import 'package:rug/features/screen_tracking/models/screen_info_model.dart';
import 'package:rug/services/logging/app_logger.dart';

class ScreenInfoRepository {
  ScreenInfoRepository._();

  static final ScreenInfoRepository instance = ScreenInfoRepository._();

  final ScreenInfoApi _api = ScreenInfoApi.instance;

  /// Submits a single screen visit to the backend.
  ///
  /// [userId] must be a valid positive integer. If it is ≤ 0 the call is
  /// skipped to avoid sending an invalid payload.
  Future<void> trackScreen({
    required int userId,
    required ScreenInfoModel entry,
  }) async {
    if (userId <= 0) {
      AppLogger.debug(
        'Skipping screen track for "${entry.screenName}" — no valid user_id yet',
      );
      return;
    }

    AppLogger.info(
      'Tracking screen view: "${entry.screenName}" (user_id: $userId)',
    );

    final success = await _api.postScreenInfo(userId: userId, entry: entry);

    if (!success) {
      AppLogger.warning(
        'Failed to save screen info for "${entry.screenName}"',
      );
    }
  }
}
