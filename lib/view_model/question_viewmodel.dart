import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/question.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_services.dart';

class QuestionViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  Future<List<Question>> fetchQuestionsForTopic(String category, String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final isPaid = prefs.getBool('isPaid') ?? false;

    if (isPaid) return await _hiveService.getQuestionsForTopic(category, topic);
    return await _firebaseService.getQuestionsForTopic(category, topic, isPaid);
  }

  Future<List<Question>> fetchQuestionsForCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final isPaid = prefs.getBool('isPaid') ?? false;

    if (isPaid) return await _hiveService.getAllQuestionsForCategory(category);
    return await _firebaseService.getAllQuestionsForCategory(category, isPaid);
  }
}
