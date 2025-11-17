import 'package:flutter/material.dart';
import '../data/models/custom_user.dart';
import '../data/models/topic.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_service.dart';
import 'user_viewmodel.dart';

class TopicViewModel extends ChangeNotifier {
  late UserViewModel _userViewModel;

  void setUserViewModel(UserViewModel userVM) {
    _userViewModel = userVM;
  }

  CustomUserModel get currentUser => _userViewModel.currentUser;
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  Future<List<(bool, Topic)>> fetchTopics(String categoryId) async {
    try {
      List<Topic> topics = [];
      if (currentUser.isPremium) {
        // topics = await _hiveService.getTopics(categoryId); // Use hive services when trying for offline storage
        topics = await _firebaseService.getTopics(categoryId); // Using temporarily, main is hive services
      }
      else {
        topics = await _firebaseService.getTopics(categoryId);
      }

      // Map sets to (bool, Set) pairs
      final List<(bool, Topic)> result = [];
      int i = 0;
      for (var topic1 in topics) {
        i += 1;
        bool isLocked = false;

        // If user is premium, unlock all sets
        if (!currentUser.isPremium && i > 2) {
          isLocked = true;
        }

        result.add((isLocked, topic1));
      }

      return result;
    } catch (e) {
      print("Error fetching topics: $e");
      return []; // Return empty list on failure
    }
  }

}