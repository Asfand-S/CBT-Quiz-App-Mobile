class CustomUserModel {
  final String id;
  String email;
  bool isPremium;
  List<String> bookmarks;
  List<String> passedQuizzes;
  List<String> unlockedTopicsNursing;
  List<String> unlockedTopicsMidwifery;
  final String? createdAt;
  String? lastActive;

  CustomUserModel({
    required this.id,
    required this.email,
    required this.isPremium,
    required this.bookmarks,
    required this.passedQuizzes,
    required this.unlockedTopicsNursing,
    required this.unlockedTopicsMidwifery,
    required this.createdAt,
    required this.lastActive,
  });

  // Factory method to create an instance from a JSON map
  factory CustomUserModel.fromMap(Map<String, dynamic> json) {
    return CustomUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      isPremium: json['isPremium'] as bool,
      bookmarks: List<String>.from(json['bookmarks'] ?? []),
      passedQuizzes: List<String>.from(json['passedQuizzes'] ?? []),
      unlockedTopicsNursing: List<String>.from(json['unlockedTopicsNursing'] ?? []),
      unlockedTopicsMidwifery: List<String>.from(json['unlockedTopicsMidwifery'] ?? []),
      createdAt: json['createdAt'] as String?,
      lastActive: json['lastActive'] as String?,
    );
  }

  // Method to convert an instance to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'isPremium': isPremium,
      'bookmarks': bookmarks,
      'passedQuizzes': passedQuizzes,
      'unlockedTopicsNursing': unlockedTopicsNursing,
      'unlockedTopicsMidwifery': unlockedTopicsMidwifery,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }

  // Method to update 1 particular field
  void update(String field, dynamic value) {
    switch (field) {
      case 'isPremium':
        isPremium = value;
        break;
      case 'bookmarks':
        bookmarks = value;
        break;
      case 'passedQuizzes':
        passedQuizzes = value;
        break;
      case 'unlockedTopicsNursing':
        unlockedTopicsNursing = value;
        break;
      case 'unlockedTopicsMidwifery':
        unlockedTopicsMidwifery = value;
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
