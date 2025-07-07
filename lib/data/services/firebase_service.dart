import 'package:cbt_quiz_android/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/topic.dart';
import '../models/set.dart';
import '../models/question.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get user => auth.currentUser;

  static Future<bool> userExist() async {
    final currentUser = auth.currentUser;

    if (currentUser == null) return false;

    final doc = await _db.collection("users").doc(currentUser.uid).get();
    return doc.exists;
  }

  static Future<void> userSignOut() async {
    return await auth.signOut();
  }

  static Future<void> createUser() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = UserModel(
      image: currentUser.photoURL ?? '',
      name: currentUser.displayName ?? '',
      about: "Hey I am using Happy Chat",
      createdAt: time,
      lastActive: time,
      id: currentUser.uid,
      email: currentUser.email ?? '',
      isPremium: false,
      bookmarks: [],
    );
    return await _db
        .collection("users")
        .doc(currentUser.uid)
        .set(chatUser.toMap());
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final currentUser = user;
      if (currentUser == null) return null;

      DocumentSnapshot doc =
          await _db.collection('users').doc(currentUser.uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print('User document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> setPremium() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      const SnackBar(content: Text("ser does not exist"));
      return;
    }

    return await _db
        .collection('users')
        .doc(currentUser.uid)
        .update({'isPremium': true});
  }

  Future<void> updateUserBookmarks(
      String userId, List<dynamic> bookmarks) async {
    await _db.collection('users').doc(userId).update({
      'bookmarks': bookmarks,
    });
  }



  Future<List<Question>> getBookmarkedQuestions(
    String categoryId,
    List<dynamic> bookmarks,
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

  Future<List<Topic>> getTopics(String categoryId) async {
    final query = await _db
        .collection('categories')
        .doc(categoryId.toLowerCase())
        .collection('topics')
        .get();
    return query.docs.map((doc) => Topic.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Set>> getSets(String categoryId, String topicId) async {
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
    
    final prefs = await SharedPreferences.getInstance();
    List<String> clearedSetsIds = prefs.getStringList("passed_quizzes") ?? [];
    List<Set> setsOpened = [];

    for (var doc in query.docs) {
      if (clearedSetsIds.contains(doc.id)) {
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
}
