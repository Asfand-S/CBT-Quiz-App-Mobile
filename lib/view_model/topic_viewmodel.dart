import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/topic.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_service.dart';

class TopicViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  Future<List<Topic>> fetchTopics(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final isPaid = prefs.getBool('isPaid') ?? false;

    try {
      if (true) {
        return await _hiveService.getTopics(categoryId);
      }
      else {
        return await _firebaseService.getTopics(categoryId);
      }
    } catch (e) {
      print("");
      print("");
      print("ERROR FETCHING TOPICS: $e");
      return []; // Return empty list on failure
    }
  }

}