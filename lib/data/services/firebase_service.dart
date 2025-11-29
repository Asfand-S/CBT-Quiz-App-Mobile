import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/topic.dart';
import '../models/set.dart';
import '../models/question.dart';
import '../models/custom_user.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get user => auth.currentUser;

  Future<List<Topic>> getTopics(String categoryId) async {
    final query = await _db
        .collection('categories')
        .doc(categoryId.toLowerCase())
        .collection('topics')
        .orderBy('createdAt')
        .get();
    return query.docs.map((doc) => Topic.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Set>> getSets(
      String categoryId, String topicId, List<String> passedQuizzes) async {
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

    // BEFORE
    // List<Set> setsOpened = [];
    // for (var doc in query.docs) {
    //   if (passedQuizzes.contains(doc.id)) {
    //     setsOpened.add(Set.fromMap(doc.id, doc.data()));
    //   } else {
    //     setsOpened.add(Set.fromMap(doc.id, doc.data()));
    //     break;
    //   }
    // }

    // AFTER
    List<Set> setsOpened = [];
    for (var doc in query.docs) {
      setsOpened.add(Set.fromMap(doc.id, doc.data()));
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

  // BOOKMARK FUNCTIONS WITH NEW LOGIC
  Future<void> addBookmark(String userId, Question question, String categoryId) async {
    String col_name = "nursing_bookmarks";
    if (categoryId == "Nursing") {
      col_name = "nursing_bookmarks";
    }
    else {
      col_name = "midwifery_bookmarks";
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection(col_name)
        .doc(question.id)
        .set(question.toMap());
  }

  Future<void> removeBookmark(String userId, String questionId, String categoryId) async {
    String col_name = "nursing_bookmarks";
    if (categoryId == "Nursing") {
      col_name = "nursing_bookmarks";
    }
    else {
      col_name = "midwifery_bookmarks";
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection(col_name)
        .doc(questionId)
        .delete();
  }

  Future<List<Question>> getBookmarkedQuestions(String userId, String categoryId) async {
    String col_name = "nursing_bookmarks";
    if (categoryId == "Nursing") {
      col_name = "nursing_bookmarks";
    }
    else {
      col_name = "midwifery_bookmarks";
    }
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection(col_name)
        .get();

    return snap.docs
        .map((doc) => Question.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<int> getBookmarkCount(String userId) async {
    final nursingCountSnap = await _db
        .collection('users')
        .doc(userId)
        .collection('nursing_bookmarks')
        .count()
        .get();


    final midwiferyCountSnap = await _db
        .collection('users')
        .doc(userId)
        .collection('midwifery_bookmarks')
        .count()
        .get();

    int totalCount = nursingCountSnap.count ?? 0;
    totalCount += midwiferyCountSnap.count ?? 0;
    return totalCount;
  }

  // New functions for Managing User Profile
  Future<CustomUserModel> getUserProfileFromFirebase(String userId) async {
    final doc = await _db.collection("users").doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final docRef = _db.collection("users").doc(userId);
      docRef.update(
          {'lastActive': DateTime.now().millisecondsSinceEpoch.toString()});
      return CustomUserModel.fromMap(doc.data()!);
    } else {
      // Create User
      final docRef = _db.collection("users").doc(userId);
      CustomUserModel user = CustomUserModel.fromMap({
        'id': userId,
        'isPremium': false,
        'passedQuizzes': [],
        'email': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      docRef.set(user.toMap());
      return user;
    }
  }

  Future<bool> updateUserData(
      String userId, String field, dynamic value) async {
    try {
      await _db.collection('users').doc(userId).update({field: value});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfEmailHasAnotherDeviceID(
      String email, String deviceID) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    for (var doc in snapshot.docs) {
      if (doc.id != deviceID) {
        return true; // Found another device with same email
      }
    }

    return false;
  }
}
