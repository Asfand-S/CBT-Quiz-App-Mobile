import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/topic.dart';
import '../data/services/firebase_service.dart';
import '../data/services/hive_services.dart';

class TopicViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final HiveService _hiveService = HiveService();

  List<Topic> _nursingTopics = [];
  List<Topic> get nursingTopics => _nursingTopics;
  List<Topic> _midwiferyTopics = [];
  List<Topic> get midwiferyTopics => _midwiferyTopics;

  Future<void> fetchTopics() async {
    final prefs = await SharedPreferences.getInstance();
    final isPaid = prefs.getBool('isPaid') ?? false;

    if (isPaid) {
      _nursingTopics = await _hiveService.getTopics("nursing");
      _midwiferyTopics = await _hiveService.getTopics("midwifery");
    }
    else {
      _nursingTopics = await _firebaseService.getTopics("nursing");
      _midwiferyTopics = await _firebaseService.getTopics("midwifery");
    }
    notifyListeners();
  }
}
