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

  Future<List<Topic>> fetchTopics(String categoryId) async {
    try {
      if (currentUser.isPremium) {
        return await _hiveService.getTopics(categoryId);
      }
      else {
        return await _firebaseService.getTopics(categoryId);
      }
    } catch (e) {
      print("Error fetching topics: $e");
      return []; // Return empty list on failure
    }
  }

}