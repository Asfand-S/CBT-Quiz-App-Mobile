class Category {
  final String id; // 'nursing' or 'midwifery'
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(id: id, name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
