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
        topics = await _hiveService.getTopics(categoryId);
      }
      else {
        topics = await _firebaseService.getTopics(categoryId);
      }

      // Map sets to (bool, Set) pairs
      final List<(bool, Topic)> result = [];
      for (var topic1 in topics) {
        bool isLocked = true;

        // If user is premium, unlock all sets
        if (currentUser.isPremium) { 
          isLocked = false; 
        }
        else {
          // If user has not unlocked 2 subjects yet, then unlock all topics so that he may choose 2 of them
          if (categoryId.toLowerCase() == "nursing" && currentUser.unlockedTopicsNursing.length < 2) { isLocked = false; }
          if (categoryId.toLowerCase() == "midwifery" && currentUser.unlockedTopicsMidwifery.length < 2) { isLocked = false; }

          // If user has unlocked 2 subjects, then only allow him access to those 2 subjects
          if (currentUser.unlockedTopicsMidwifery.contains(topic1.id) || currentUser.unlockedTopicsNursing.contains(topic1.id)) {
            isLocked = false;
          }
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