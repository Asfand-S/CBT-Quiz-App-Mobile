class Topic {
  final String id;
  final String name;

  Topic({required this.id, required this.name});

  factory Topic.fromMap(String id, Map<String, dynamic> map) {
    return Topic(id: id, name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
