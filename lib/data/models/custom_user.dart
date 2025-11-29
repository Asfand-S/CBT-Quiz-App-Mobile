class CustomUserModel {
  final String id;
  String email;
  bool isPremium;
  List<String> passedQuizzes;
  final String? createdAt;
  String? lastActive;

  CustomUserModel({
    required this.id,
    required this.email,
    required this.isPremium,
    required this.passedQuizzes,
    required this.createdAt,
    required this.lastActive,
  });

  factory CustomUserModel.fromMap(Map<String, dynamic> json) {
    return CustomUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      isPremium: json['isPremium'] as bool,
      passedQuizzes: List<String>.from(json['passedQuizzes'] ?? []),
      createdAt: json['createdAt'] as String?,
      lastActive: json['lastActive'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'isPremium': isPremium,
      'passedQuizzes': passedQuizzes,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }

  void update(String field, dynamic value) {
    switch (field) {
      case 'isPremium':
        isPremium = value;
        break;
      case 'passedQuizzes':
        passedQuizzes = value;
        break;
      case 'lastActive':
        lastActive = value;
        break;
      case 'email':
        email = value;
        break;
      default:
        break;
    }
  }
}
