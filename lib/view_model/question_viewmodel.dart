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
        questions = await _hiveService.getQuestions(categoryId, topicId, setId);
      }
      else {
        questions = await _firebaseService.getQuestions(categoryId, topicId, setId);
        if (questions.length > 2) questions = questions.sublist(0, 2);
      }
      return questions;
    }
    catch (e) {
      print("Error fetching questions: $e");
      return []; // Return empty list on failure
    }
  }
}
