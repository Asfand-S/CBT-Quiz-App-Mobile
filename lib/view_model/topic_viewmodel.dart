import 'package:flutter/material.dart';
import '../data/models/topic.dart';
import '../data/services/firebase_service.dart';

class TopicViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Topic>> fetchTopics(String categoryId) async {
    try {
      return await _firebaseService.getTopics(categoryId);
    } catch (e) {
      print("Error fetching topics: $e");
      return []; // Return empty list on failure
    }
  }
}