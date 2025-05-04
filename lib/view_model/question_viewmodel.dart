import 'package:flutter/material.dart';
import '../data/models/question.dart';
import '../data/services/firebase_service.dart';

class QuestionViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Question>> fetchQuestionsForTopic(String category, String topic) async {
    return await _firebaseService.getQuestions(category, topic);
  }

  Future<List<Question>> fetchQuestionsForCategory(String category) async {
    return await _firebaseService.getAllQuestionsForCategory(category);
  }
}
