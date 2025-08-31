import 'package:flutter/material.dart';
import '../data/models/custom_user.dart';
import '../data/models/set.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_service.dart';
import 'user_viewmodel.dart';

class SetViewModel extends ChangeNotifier {
  late UserViewModel _userViewModel;

  void setUserViewModel(UserViewModel userVM) {
    _userViewModel = userVM;
  }

  CustomUserModel get currentUser => _userViewModel.currentUser;
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  // BEFORE
  Future<List<Set>> fetchSets1(String categoryId, String topicId) async {
    List<Set> sets = [];
    try {
      if (currentUser.isPremium) {
        sets = await _hiveService.getSets(
            categoryId, topicId, currentUser.passedQuizzes);
      } else {
        sets = await _firebaseService.getSets(
            categoryId, topicId, currentUser.passedQuizzes);
        if (sets.length > 2) sets = sets.sublist(0, 2);
      }
      return sets;
    } catch (e) {
      print("Error fetching sets: $e");
      return []; // Return empty list on failure
    }
  }

  // AFTER
  Future<List<(bool, Set)>> fetchSets(String categoryId, String topicId) async {
    List<Set> sets = [];
    try {
      if (currentUser.isPremium) {
        sets = await _hiveService.getSets(
            categoryId, topicId, currentUser.passedQuizzes);
      } else {
        sets = await _firebaseService.getSets(
            categoryId, topicId, currentUser.passedQuizzes);
      }

      // Map sets to (bool, Set) pairs
      final List<(bool, Set)> result = [];
      bool latest_set = false;
      for (var set1 in sets) {
        bool isLocked = false;
        if (currentUser.passedQuizzes.contains(set1.id)) {
          isLocked = false;
        } else {
          if (!latest_set) {
            latest_set = true;
            isLocked = false;
          } else {
            isLocked = true;
          }
        }
        result.add((isLocked, set1));
      }

      return result;
    } catch (e) {
      print("Error fetching sets: $e");
      return []; // Return empty list on failure
    }
  }
}
