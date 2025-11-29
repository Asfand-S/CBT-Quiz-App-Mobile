import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/question.dart';
import '../data/models/custom_user.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_service.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  late final CustomUserModel _currentUser;
  CustomUserModel get currentUser => _currentUser;

  Future<void> init() async {
    _isOnline = await isConnectedToInternet();
    final deviceId = await _getDeviceID();
    _currentUser = await getUserProfile(deviceId);

    // Premium User Online
    if (_currentUser.isPremium && _isOnline) {
      await _hiveService.ensureLocalQuizData();
      await ensureLocalUserData();
      // await _hiveService.printLocalDataSummary();
    }
    notifyListeners();
  }

  Future<String> _getDeviceID() async {
    const platform = MethodChannel('device/info');
    try {
      return await platform.invokeMethod('deviceId');
    } catch (e) {
      print('Error fetching device details: $e');
      return '';
    }
  }

  Future<CustomUserModel> getUserProfile(String userId) async {
    final isPremium = await isCurrentUserPremium();
    if (isPremium && !_isOnline) {
      return await getUserProfileFromSharedPrefs(userId);
    }
    else {
      final user = await _firebaseService.getUserProfileFromFirebase(userId);
      updateSharedPrefsProfile(user);
      return user;
    }
  }

  Future<void> updateSharedPrefsProfile(CustomUserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    // If first time app run
    if (!prefs.containsKey('userId')) {
      await prefs.setString('userId', user.id);
      await prefs.setBool('isPremium', user.isPremium);
      await prefs.setStringList('passedQuizzes', user.passedQuizzes);
      await prefs.setString('lastActive', user.lastActive!);
      await prefs.setString('email', user.email);
    }
  }

  Future<CustomUserModel> getUserProfileFromSharedPrefs(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    bool isPremium = false;
    List<String> bookmarks = [];
    List<String> passedQuizzes = [];
    String lastActive = "0";
    String email = "";

    // If first time app run
    if (!prefs.containsKey('userId')) {
      await prefs.setString('userId', userId);
      await prefs.setBool('isPremium', isPremium);
      await prefs.setStringList('passedQuizzes', passedQuizzes);
      await prefs.setString('lastActive', lastActive);
      await prefs.setString('email', email);
    } else {
      isPremium = prefs.getBool('isPremium') ?? false;
      passedQuizzes = prefs.getStringList('passedQuizzes') ?? [];
      lastActive = prefs.getString('lastActive') ?? "";
      email = prefs.getString('email') ?? "";
    }

    CustomUserModel user = CustomUserModel.fromMap({
      'id': userId,
      'isPremium': isPremium,
      'bookmarks': bookmarks,
      'passedQuizzes': passedQuizzes,
      'email': email,
      'createdAt': '',
      'lastActive': lastActive,
    });
    return user;
  }

  Future<void> ensureLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _currentUser.id);
    await prefs.setBool('isPremium', _currentUser.isPremium);
    await prefs.setStringList('passedQuizzes', _currentUser.passedQuizzes);
    await prefs.setString('lastActive', _currentUser.lastActive!);
  }

  Future<bool> canAccessApp() async {
    final isOnline = await isConnectedToInternet();
    final isPremium = await isCurrentUserPremium();

    return isPremium || isOnline;
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

  Future<bool> isCurrentUserPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPremium') ?? false;
  }

  Future<void> updateUserData(String field, dynamic value) async {
    final result =
        await _firebaseService.updateUserData(_currentUser.id, field, value);

    if (result) {
      _currentUser.update(field, value);
      final prefs = await SharedPreferences.getInstance();

      switch (field) {
        case 'isPremium':
          _hiveService.ensureLocalQuizData();
          ensureLocalUserData();
          await prefs.setBool('isPremium', value);
          break;
        case 'passedQuizzes':
          await prefs.setStringList('passedQuizzes', value);
          break;
        case 'lastActive':
          await prefs.setString('lastActive', value);
          break;
        case 'email':
          await prefs.setString('email', value);
          break;
        default:
          break;
      }
    }
    notifyListeners();
  }



  Future<void> addBookmark(Question question, String categoryId) async {
    await _firebaseService.addBookmark(_currentUser.id, question, categoryId);
  }

  Future<void> removeBookmark(String questionId, String categoryId) async {
    await _firebaseService.removeBookmark(_currentUser.id, questionId, categoryId);
  }

  Future<int> getBookmarkCount() async {
    return await _firebaseService.getBookmarkCount(_currentUser.id);
  }

  Future<List<Question?>> getBookmarkedQuestions(String categoryId) async {
    return await _firebaseService.getBookmarkedQuestions(_currentUser.id, categoryId);
  }

  Future<void> updatePassedQuizzes(String quizId, double percentage) async {
    if (percentage < 60) return;

    final passedQuizzes = currentUser.passedQuizzes;
    if (passedQuizzes.contains(quizId)) return;

    passedQuizzes.add(quizId);
    updateUserData("passedQuizzes", passedQuizzes);
  }

  Future<List<String>> getPassedQuizzes() async {
    return currentUser.passedQuizzes;
  }
}
