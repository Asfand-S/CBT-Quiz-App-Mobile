import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/question.dart';
import '../data/models/user.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_services.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isPaid = false;
  bool get isPaid => _isPaid;

  int _lastActive = 0;
  int get lastActive => _lastActive;

  late final UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> init() async {
    await getValuesFromSharedPrefs();
    _isOnline = await isConnectedToInternet();
    // _currentUser = await _firebaseService.getCurrentUserProfile();

    if (isPaid && isOnline) {
      await _hiveService.ensureLocalData();
    }
    notifyListeners();
  }

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    // Check if the result is mobile or wifi
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    }

    return false;
  }

  Future<void> getValuesFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPaid', false);

    // If 'isPaid' doesn't exist, set it to false
    if (!prefs.containsKey('isPaid')) {
      await prefs.setBool('isPaid', false);
      _isPaid = false;
    } else {
      _isPaid = prefs.getBool('isPaid')!;
    }

    // If 'lastActive' doesn't exist, set it to current time
    if (!prefs.containsKey('lastActive')) {
      await prefs.setInt('lastActive', 0);
      _lastActive = 0;
    } else {
      _lastActive = prefs.getInt('lastActive')!;
    }

    // If 'bookmarks' doesn't exist, set it to empty list
    if (!prefs.containsKey('bookmarks')) {
      await prefs.setStringList('bookmarks', []);
    }

    // If 'passed_quizzes' doesn't exist, set it to empty list
    if (!prefs.containsKey('passed_quizzes')) {
      await prefs.setStringList('passed_quizzes', []);
    }
  }

  Future<bool> canAccessApp() async {
    final isConnected = await isConnectedToInternet();
    return _isPaid || isConnected;
  }

  Future<String> addBookmark(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];

    if (bookmarks.contains(questionId)) {
      return "Question already bookmarked.";
    } else if (!isPaid && bookmarks.length >= 5) {
      return "You can only bookmark 5 questions.";
    } else {
      bookmarks.add(questionId);
      await prefs.setStringList("bookmarks", bookmarks);
      // await _firebaseService.updateUserBookmarks(
      //     _currentUser!.id, _currentUser!.bookmarks);
      notifyListeners();
      return "Bookmark added successfully.";
    }
  }

  Future<List<Question?>> getBookmarkedQuestions(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];

    if (_currentUser == null || bookmarks.isEmpty) {
      return [];
    } else {
      return await _firebaseService.getBookmarkedQuestions(
          categoryId, _currentUser.bookmarks);
    }
  }

  Future<List<String>> getPassedQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('passed_quizzes') ?? [];
  }

  Future<void> updatePassedQuizzes(String quizId, double percentage) async {
    if (percentage < 60) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> passedQuizzes = prefs.getStringList('passed_quizzes') ?? [];
    passedQuizzes.add(quizId);
    await prefs.setStringList('passed_quizzes', passedQuizzes);
  }
}
