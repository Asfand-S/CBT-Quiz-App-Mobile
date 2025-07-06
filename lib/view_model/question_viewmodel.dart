import 'package:flutter/material.dart';
import '../data/models/question.dart';
import '../data/services/firebase_service.dart';

class QuestionViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Question>> fetchQuestions(
      String categoryId, String topicId, String setId) async {
    try {
      return await _firebaseService.getQuestions(
          categoryId: categoryId, topicId: topicId, setId: setId);
    } catch (e) {
      print("Error fetching questions: $e");
      return []; // Return empty list on failure
    }
  }
}
