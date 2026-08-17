import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rug/shared/models/user_model.dart';
import 'package:rug/shared/providers/common_providers.dart';

void main() {
  group('Username Gate & UserModel Parsing Tests', () {
    test('UserModel.parseIsUsernameSet helper handles all data types correctly', () {
      // 1. Null username or empty username always returns false
      expect(UserModel.parseIsUsernameSet(true, null), false);
      expect(UserModel.parseIsUsernameSet(true, ''), false);
      expect(UserModel.parseIsUsernameSet(true, '   '), false);

      // 2. Boolean values
      expect(UserModel.parseIsUsernameSet(true, 'card_king'), true);
      expect(UserModel.parseIsUsernameSet(false, 'card_king'), false);

      // 3. Numeric values (0 = false, 1 = true)
      expect(UserModel.parseIsUsernameSet(0, 'card_king'), false);
      expect(UserModel.parseIsUsernameSet(1, 'card_king'), true);

      // 4. String values ("false"/"0" = false, "true"/"1" = true)
      expect(UserModel.parseIsUsernameSet('false', 'card_king'), false);
      expect(UserModel.parseIsUsernameSet('0', 'card_king'), false);
      expect(UserModel.parseIsUsernameSet('true', 'card_king'), true);
      expect(UserModel.parseIsUsernameSet('1', 'card_king'), true);

      // 5. Null value defaults to true ONLY if username is non-empty
      expect(UserModel.parseIsUsernameSet(null, 'card_king'), true);
      expect(UserModel.parseIsUsernameSet(null, null), false);
    });

    test('UserModel.fromJson parses exact social login backend response with username: null & is_username_set: false', () {
      final jsonPayload = {
        'id': 13,
        'device_id': '81395ae2aede0f86',
        'socket_id': null,
        'username': null,
        'profile': null,
        'profile_url': 'https://lh3.googleusercontent.com/a/ACg8ocKFQwxtdOf6ZRBg3aKgdF8fnxQBF9UBMRmMQsz0_UAbSXqtWJY=s96-c',
        'email': 'parth19.developer@gmail.com',
        'user_type': 'user',
        'login_type': 'google',
        'is_verified': true,
        'is_social_login': true,
        'social_media_id': '105383329379393885990',
        'social_media_type': 'google',
        'created_at': '2026-08-16T15:56:23.366Z',
        'updated_at': '2026-08-16T15:56:23.366Z',
        'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        'is_username_set': false
      };

      final user = UserModel.fromJson(jsonPayload);
      expect(user.id, '13');
      expect(user.email, 'parth19.developer@gmail.com');
      expect(user.username, '');
      expect(user.isUsernameSet, false);
      expect(
        user.avatarUrl,
        'https://lh3.googleusercontent.com/a/ACg8ocKFQwxtdOf6ZRBg3aKgdF8fnxQBF9UBMRmMQsz0_UAbSXqtWJY=s96-c',
      );
    });

    test('UserModel.fromJson parses is_username_set correctly', () {
      // Test explicit false in JSON
      final user1 = UserModel.fromJson({
        'id': '101',
        'username': 'social_user_101',
        'email': 'social@example.com',
        'is_username_set': false,
      });
      expect(user1.isUsernameSet, false);

      // Test integer 0 in JSON
      final user2 = UserModel.fromJson({
        'id': '102',
        'username': 'social_user_102',
        'is_username_set': 0,
      });
      expect(user2.isUsernameSet, false);

      // Test missing username / empty string
      final user3 = UserModel.fromJson({
        'id': '103',
        'username': '',
        'is_username_set': true,
      });
      expect(user3.isUsernameSet, false);

      // Test valid user with set username
      final user4 = UserModel.fromJson({
        'id': '104',
        'username': 'rug_master',
        'is_username_set': true,
      });
      expect(user4.isUsernameSet, true);
    });

    test('currentUserProvider correctly reflects username initialization state', () {
      final container = ProviderContainer();

      // Initial state
      expect(container.read(currentUserProvider), null);

      // Set user without initialized username
      final uninitUser = UserModel.fromJson({
        'id': '201',
        'username': null,
        'email': 'new_social@example.com',
        'is_username_set': false,
      });
      container.read(currentUserProvider.notifier).setUser(uninitUser);

      final current = container.read(currentUserProvider);
      expect(current, isNotNull);
      expect(current!.isUsernameSet, false);
      expect(current.username, '');

      // Set user after setting username
      final initUser = UserModel(
        id: '201',
        username: 'pro_player',
        email: 'new_social@example.com',
        isUsernameSet: true,
      );
      container.read(currentUserProvider.notifier).setUser(initUser);

      final updated = container.read(currentUserProvider);
      expect(updated!.isUsernameSet, true);
      expect(updated.username, 'pro_player');

      container.dispose();
    });
  });
}
