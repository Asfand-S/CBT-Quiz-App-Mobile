import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/set.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_service.dart';

class SetViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  Future<List<Set>> fetchSets(String categoryId, String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final isPaid = prefs.getBool('isPaid') ?? false;

    try {
      if (isPaid) {
        return await _hiveService.getSets(categoryId, topicId);
      }
      else {
        return await _firebaseService.getSets(categoryId, topicId);
      }
    } catch (e) {
      print("Error fetching sets: $e");
      return []; // Return empty list on failure
    }
  }
}