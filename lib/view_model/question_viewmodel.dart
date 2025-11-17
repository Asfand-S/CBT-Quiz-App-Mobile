import 'package:flutter/material.dart';
import '../data/models/custom_user.dart';
import '../data/models/question.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_service.dart';
import 'user_viewmodel.dart';

class QuestionViewModel extends ChangeNotifier {
  late UserViewModel _userViewModel;

  void setUserViewModel(UserViewModel userVM) {
    _userViewModel = userVM;
  }

  CustomUserModel get currentUser => _userViewModel.currentUser;
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  Future<List<Question>> fetchQuestions(String categoryId, String topicId, String setId) async {
    List<Question> questions = [];
    try {
      if (currentUser.isPremium) {
        // questions = await _hiveService.getQuestions(categoryId, topicId, setId); // Use hive services when trying for offline storage
        questions = await _firebaseService.getQuestions(categoryId, topicId, setId); // Using temporarily, main is hive services
      }
      else {
        questions = await _firebaseService.getQuestions(categoryId, topicId, setId);
      }
      return questions;
    }
    catch (e) {
      print("Error fetching questions: $e");
      return []; // Return empty list on failure
    }
  }
}
