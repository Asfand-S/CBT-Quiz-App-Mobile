import 'package:flutter/material.dart';
import '../data/models/set.dart';
import '../data/services/firebase_service.dart';

class SetViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Set>> fetchSets(String categoryId, String topicId) async {
    try {
      return await _firebaseService.getSets(categoryId, topicId);
    } catch (e) {
      print("Error fetching sets: $e");
      return []; // Return empty list on failure
    }
  }
}