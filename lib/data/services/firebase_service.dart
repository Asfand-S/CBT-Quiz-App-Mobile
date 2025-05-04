import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question.dart';
import '../models/topic.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Topic>> getTopics(String category) async {
    final snapshot = await _db
        .collection('categories')
        .doc(category)
        .collection('topics')
        .get();

    return snapshot.docs.map((doc) => Topic.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Question>> getQuestions(String category, String topicId) async {
    final snapshot = await _db
        .collection('categories')
        .doc(category)
        .collection('topics')
        .doc(topicId)
        .collection('questions')
        .get();

    return snapshot.docs.map((doc) => Question.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Question>> getAllQuestionsForCategory(String category) async {
    final topicsSnapshot = await _db
        .collection('categories')
        .doc(category)
        .collection('topics')
        .get();

    List<Question> allQuestions = [];

    for (final topicDoc in topicsSnapshot.docs) {
      final questionsSnapshot = await topicDoc.reference.collection('questions').get();

      final questions = questionsSnapshot.docs.map((doc) {
        return Question.fromMap(doc.id, doc.data());
      }).toList();

      allQuestions.addAll(questions);
    }

    return allQuestions;
  }
}
