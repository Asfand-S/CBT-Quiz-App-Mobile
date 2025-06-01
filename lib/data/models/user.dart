class UserModel {
  final String image;
  final String name;
  final String about;
  final String? createdAt; // Change to String?
  final bool isOnline;
  final String? lastActive; // Change to String?
  final String id;
  final String email;
  final String? pushToken;
  final bool isPremium;
  final List<dynamic> bookmarks;

  UserModel({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.lastActive,
    required this.id,
    required this.email,
    required this.isPremium,
    required this.bookmarks,
    this.pushToken,
  });

  // Factory method to create an instance from a JSON map
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      image: json['image'] as String,
      name: json['name'] as String,
      about: json['about'] as String,
      createdAt: json['created_at'] as String?, // Handle nullable string
      isOnline: json['is_online'] as bool,
      lastActive: json['last_active'] as String?, // Handle nullable string
      id: json['id'] as String,
      email: json['email'] as String,
      pushToken: json['push_token'] as String?, // Nullable string
      isPremium: json['is_premium'] as bool,
      bookmarks: json['bookmarks'],
    );
  }

  // Method to convert an instance to JSON map
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'about': about,
      'created_at': createdAt, // Already a string
      'is_online': isOnline,
      'last_active': lastActive, // Already a string
      'id': id,
      'email': email,
      'push_token': pushToken, // Nullable string
      'is_premium': isPremium,
      'bookmarks': bookmarks
    };
  }
}
