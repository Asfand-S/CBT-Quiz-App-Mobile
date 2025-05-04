import 'package:flutter/material.dart';
import '../data/models/topic.dart';
import '../data/services/firebase_service.dart';

class TopicViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Topic> _nursingTopics = [];
  List<Topic> get nursingTopics => _nursingTopics;
  List<Topic> _midwiferyTopics = [];
  List<Topic> get midwiferyTopics => _midwiferyTopics;

  Future<void> fetchTopics() async {
    _nursingTopics = await _firebaseService.getTopics("nursing");
    _midwiferyTopics = await _firebaseService.getTopics("midwifery");
    notifyListeners();
  }
}
