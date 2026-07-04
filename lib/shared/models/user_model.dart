/// Shared user model placeholder.
///
/// Represents the core user data shared across features.
/// Will be enhanced with Freezed code generation when implemented.
library;

class UserModel {

  /// Creates from JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      displayName: json['display_name'] as String?,
      level: json['level'] as int?,
      totalWins: json['total_wins'] as int?,
      totalGames: json['total_games'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
  const UserModel({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    this.displayName,
    this.level,
    this.totalWins,
    this.totalGames,
    this.createdAt,
  });

  final String id;
  final String username;
  final String? email;
  final String? avatarUrl;
  final String? displayName;
  final int? level;
  final int? totalWins;
  final int? totalGames;
  final DateTime? createdAt;

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'display_name': displayName,
      'level': level,
      'total_wins': totalWins,
      'total_games': totalGames,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Win rate percentage.
  double get winRate {
    if (totalGames == null || totalGames == 0) return 0.0;
    return (totalWins ?? 0) / totalGames! * 100;
  }
}
