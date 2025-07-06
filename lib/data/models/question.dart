import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 2)
class Question {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final List<String> options;

  @HiveField(3)
  final int correctIndex;

  @HiveField(4)
  final String explanation;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation
    };
  }

  factory Question.fromMap(String id, Map<String, dynamic> map) {
    return Question(
      id: id,
      question: map['question'],
      options: List<String>.from(map['options']),
      correctIndex: map['correctIndex'],
      explanation: map['explanation'],
    );
  }
}
