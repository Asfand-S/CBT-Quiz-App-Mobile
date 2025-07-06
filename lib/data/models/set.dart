import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'set.g.dart';

@HiveType(typeId: 3)
class Set {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime? lastUpdated;

  Set({
    required this.id,
    required this.name,
    this.lastUpdated,
  });

  factory Set.fromMap(String id, Map<String, dynamic> map) {
    return Set(
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
