class UserModel {
  final String username;
  final String profileImageUrl;

  UserModel({
    required this.username,
    required this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
    );
  }
}
