import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/question.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_service.dart';

class QuestionViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  Future<List<Question>> fetchQuestions(String categoryId, String topicId, String setId) async {
    final prefs = await SharedPreferences.getInstance();
    final isPaid = prefs.getBool('isPaid') ?? false;

    try {
      if (isPaid) {
        return await _hiveService.getQuestions(categoryId, topicId, setId);
      }
      else {
        return await _firebaseService.getQuestions(categoryId, topicId, setId);
      }
    } catch (e) {
      print("Error fetching questions: $e");
      return []; // Return empty list on failure
    }
  }
}
