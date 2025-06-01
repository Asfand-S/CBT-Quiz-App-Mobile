import 'package:cbt_quiz_android/data/models/user.dart';
import 'package:flutter/material.dart';
import '../data/models/question.dart';
import '../data/services/firebase_service.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> loadUser() async {
    _currentUser = await _firebaseService.getCurrentUserProfile();
    notifyListeners();
  }

  Future<void> addBookmark(String questionId) async {
    loadUser();
    print(currentUser);
    print(questionId);
    if (_currentUser == null) return;

    if (!(_currentUser!.bookmarks.contains(questionId))) {
      _currentUser!.bookmarks.add(questionId);
      await _firebaseService.updateUserBookmarks(
          _currentUser!.id, _currentUser!.bookmarks);
      notifyListeners();
    }
  }

  Future<List<Question?>> getBookmarkedQuestions(String category) async {
    if (_currentUser == null || _currentUser?.bookmarks == null) {
      return [];
    } else {
      return await _firebaseService.getBookmarkedQuestions(
          category, _currentUser!.bookmarks);
    }
  }
}
