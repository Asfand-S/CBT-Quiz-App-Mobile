import 'package:flutter/material.dart';
import '../data/models/question.dart';
import '../data/models/custom_user.dart';
import 'user_viewmodel.dart';

class QuizViewModel extends ChangeNotifier {
  late UserViewModel _userViewModel;

  void setUserViewModel(UserViewModel userVM) {
    _userViewModel = userVM;
  }

  CustomUserModel get currentUser => _userViewModel.currentUser;
  late List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;
  late DateTime _startTime;
  late DateTime _endTime;

  void startQuiz(List<Question> questions) {
    _questions = questions;
    _questions.shuffle();
    _currentIndex = 0;
    _score = 0;
    _startTime = DateTime.now();
    notifyListeners();
  }

  Question get currentQuestion => _questions[_currentIndex];
  int get currentIndex => _currentIndex;
  int get totalQuestions => _questions.length;
  int get score => _score;

  void submitAnswer(int selectedIndex) {
    if (currentQuestion.correctIndex == selectedIndex) {
      _score++;
    }
    _currentIndex++;
    notifyListeners();
  }

  bool get isQuizOver => _currentIndex >= _questions.length;

  Duration completeQuiz() {
    _endTime = DateTime.now();
    return _endTime.difference(_startTime);
  }

  void resetQuiz() {
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
  }
}
