import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'topic.g.dart';

@HiveType(typeId: 1)
class Topic {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime? lastUpdated;

  Topic({
    required this.id,
    required this.name,
    this.lastUpdated,
  });

  factory Topic.fromMap(String id, Map<String, dynamic> map) {
    return Topic(
      id: id,
      name: map['name'],
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lastUpdated': lastUpdated,
    };
  }
}
