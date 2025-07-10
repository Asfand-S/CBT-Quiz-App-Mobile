import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/topic.dart';
import '../models/set.dart';
import '../models/question.dart';
import '../models/custom_user.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get user => auth.currentUser;

  Future<List<Topic>> getTopics(String categoryId) async {
    final query = await _db
        .collection('categories')
        .doc(categoryId.toLowerCase())
        .collection('topics')
        .get();
    return query.docs.map((doc) => Topic.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Set>> getSets(String categoryId, String topicId, List<String> passedQuizzes) async {
    QuerySnapshot<Map<String, dynamic>> query;

    if (topicId == "") {
      query = await _db
          .collection('categories')
          .doc(categoryId.toLowerCase())
          .collection('mock_sets')
          .orderBy('createdAt')
          .get();
    } else {
      query = await _db
          .collection('categories')
          .doc(categoryId.toLowerCase())
          .collection('topics')
          .doc(topicId)
          .collection('sets')
          .orderBy('createdAt')
          .get();
    }
    
    List<Set> setsOpened = [];
    for (var doc in query.docs) {
      if (passedQuizzes.contains(doc.id)) {
        setsOpened.add(Set.fromMap(doc.id, doc.data()));
      }
      else {
        setsOpened.add(Set.fromMap(doc.id, doc.data()));
        break;
      }
    }

    return setsOpened;
  }

  Future<List<Question>> getQuestions(
    String categoryId,
    String topicId,
    String setId,
  ) async {
    if (topicId == "") {
      final query = await _db
          .collection('categories')
          .doc(categoryId.toLowerCase())
          .collection('mock_sets')
          .doc(setId)
          .collection('questions')
          .get();

      return query.docs
          .map((doc) => Question.fromMap(doc.id, doc.data()))
          .toList();
    } else {
      final query = await _db
          .collection('categories')
          .doc(categoryId.toLowerCase())
          .collection('topics')
          .doc(topicId)
          .collection('sets')
          .doc(setId)
          .collection('questions')
          .get();

      return query.docs
          .map((doc) => Question.fromMap(doc.id, doc.data()))
          .toList();
    }
  }

  Future<List<Question>> getBookmarkedQuestions(
    String categoryId,
    List<String> bookmarks,
  ) async {
    final List<Question> bookmarkedQuestions = [];

    final categoryRef = _db.collection('categories').doc(categoryId.toLowerCase());

    // Step 1: Get all topics
    final topicsSnapshot = await categoryRef.collection('topics').get();

    for (final topicDoc in topicsSnapshot.docs) {
      final topicId = topicDoc.id;

      // Step 2: Get all sets in this topic
      final setsSnapshot = await categoryRef.collection('topics').doc(topicId).collection('sets').get();

      for (final setDoc in setsSnapshot.docs) {
        final setId = setDoc.id;

        // Step 3: Get all questions in this set
        final questionsSnapshot = await categoryRef
            .collection('topics')
            .doc(topicId)
            .collection('sets')
            .doc(setId)
            .collection('questions')
            .get();

        for (final questionDoc in questionsSnapshot.docs) {
          final questionData = questionDoc.data();
          final questionId = questionDoc.id;

          if (bookmarks.contains(questionId)) {
            bookmarkedQuestions.add(Question.fromMap(questionId, questionData));
          }
        }
      }
    }

    return bookmarkedQuestions;
  }



  // New functions for Managing User Profile
  Future<CustomUserModel> getUserProfileFromFirebase(String userId) async {
    final doc = await _db.collection("users").doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final docRef = _db.collection("users").doc(userId);
      docRef.update({'lastActive': DateTime.now().millisecondsSinceEpoch.toString()});
      return CustomUserModel.fromMap(doc.data()!);
    } 
    else {
      // Create User
      final docRef = _db.collection("users").doc(userId);
      CustomUserModel user = CustomUserModel.fromMap({
        'id': userId,
        'isPremium': false,
        'bookmarks': [],
        'passedQuizzes': [],
        'unlockedTopicsNursing': [],
        'unlockedTopicsMidwifery': [],
        'email': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      docRef.set(user.toMap());
      return user;
    }
  }

  Future<bool> updateUserData(String userId, String field, dynamic value) async {
    try {
      await _db
        .collection('users')
        .doc(userId)
        .update({field: value});
      return true;
    } catch (e) {
      return false;
    }
  }
}
