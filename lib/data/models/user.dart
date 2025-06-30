class UserModel {
  final String image;
  final String name;
  final String about;
  final String? createdAt; // Change to String?
  final String? lastActive; // Change to String?
  final String id;
  final String email;

  final bool isPremium;
  final List<dynamic> bookmarks;

  UserModel({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.lastActive,
    required this.id,
    required this.email,
    required this.isPremium,
    required this.bookmarks,
  });

  // Factory method to create an instance from a JSON map
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      image: json['image'] as String,
      name: json['name'] as String,
      about: json['about'] as String,
      createdAt: json['created_at'] as String?, // Handle nullable string
      lastActive: json['last_active'] as String?, // Handle nullable string
      id: json['id'] as String,
      email: json['email'] as String,
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
      'last_active': lastActive, // Already a string
      'id': id,
      'email': email,
      'is_premium': isPremium,
      'bookmarks': bookmarks
    };
  }
}
