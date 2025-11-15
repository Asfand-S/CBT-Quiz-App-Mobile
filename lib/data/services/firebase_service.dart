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

  Future<List<Question>> getBookmarkedQuestions1(
    String categoryId,
    List<String> bookmarks,
  ) async {
    final List<Question> bookmarkedQuestions = [];

    final categoryRef =
        _db.collection('categories').doc(categoryId.toLowerCase());

    // Step 1: Get all topics
    final topicsSnapshot = await categoryRef.collection('topics').get();

    for (final topicDoc in topicsSnapshot.docs) {
      final topicId = topicDoc.id;

      // Step 2: Get all sets in this topic
      final setsSnapshot = await categoryRef
          .collection('topics')
          .doc(topicId)
          .collection('sets')
          .get();

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

    // Step 1: Get all mock sets
    final mockSetsSnapshot = await categoryRef.collection('mock_sets').get();

    for (final setDoc in mockSetsSnapshot.docs) {
      final setId = setDoc.id;

      // Step 3: Get all questions in this set
      final questionsSnapshot = await categoryRef
          .collection('mock_sets')
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

    return bookmarkedQuestions;
  }

  Future<List<Question>> getBookmarkedQuestions2(
    String categoryId,
    List<String> bookmarks,
  ) async {
    if (bookmarks.isEmpty) return [];

    const batchSize = 10;
    final List<Question> bookmarkedQuestions = [];
    final categoryPath = 'categories/${categoryId.toLowerCase()}';

    for (var i = 0; i < bookmarks.length; i += batchSize) {
      final batch = bookmarks.sublist(
        i,
        i + batchSize > bookmarks.length ? bookmarks.length : i + batchSize,
      );

      // Single query across all "questions" subcollections
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('questions')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      for (final doc in querySnapshot.docs) {
        // Filter only documents belonging to this category
        if (doc.reference.path.startsWith(categoryPath)) {
          bookmarkedQuestions.add(Question.fromMap(doc.id, doc.data()));
        }
      }
    }

    return bookmarkedQuestions;
  }

  Future<List<Question>> getBookmarkedQuestions3(
    String categoryId,
    List<String> bookmarkIds,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final List<Question> bookmarkedQuestions = [];
    final categoryRef =
        firestore.collection('categories').doc(categoryId.toLowerCase());

    // Helper to chunk bookmarkIds (Firestore allows max 10 in whereIn)
    Iterable<List<T>> chunk<T>(List<T> list, int size) sync* {
      for (var i = 0; i < list.length; i += size) {
        yield list.sublist(i, i + size > list.length ? list.length : i + size);
      }
    }

    // --- 1️⃣ Search inside mock_sets/{mockSetId}/questions/{questionId} ---
    final mockSetsSnapshot = await categoryRef.collection('mock_sets').get();
    for (final mockSetDoc in mockSetsSnapshot.docs) {
      final questionsRef = mockSetDoc.reference.collection('questions');

      for (final batch in chunk(bookmarkIds, 10)) {
        final snapshot = await questionsRef
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          bookmarkedQuestions.add(Question.fromMap(doc.id, doc.data()));
        }
      }
    }

    // --- 2️⃣ Search inside topics/{topicId}/sets/{setId}/questions/{questionId} ---
    final topicsSnapshot = await categoryRef.collection('topics').get();
    for (final topicDoc in topicsSnapshot.docs) {
      final setsSnapshot = await topicDoc.reference.collection('sets').get();

      for (final setDoc in setsSnapshot.docs) {
        final questionsRef = setDoc.reference.collection('questions');

        for (final batch in chunk(bookmarkIds, 10)) {
          final snapshot = await questionsRef
              .where(FieldPath.documentId, whereIn: batch)
              .get();

          for (final doc in snapshot.docs) {
            bookmarkedQuestions.add(Question.fromMap(doc.id, doc.data()));
          }
        }
      }
    }

    return bookmarkedQuestions;
  }

  Future<List<Question>> getBookmarkedQuestions(
    String categoryId,
    List<String> bookmarks,
  ) async {
    final List<Question> bookmarkedQuestions = [];
    final categoryRef =
        _db.collection('categories').doc(categoryId.toLowerCase());
    final bool isPremium = false;

    if (bookmarks.isEmpty) return [];

    // 🔹 Split bookmarks into batches of 10 (max whereIn limit)
    final batches = <List<String>>[];
    for (var i = 0; i < bookmarks.length; i += 10) {
      batches.add(bookmarks.sublist(
          i, i + 10 > bookmarks.length ? bookmarks.length : i + 10));
    }

    // =============================
    // 🔸 1. Handle Mock Sets
    // =============================
    Query<Map<String, dynamic>> mockSetsQuery =
        categoryRef.collection('mock_sets').orderBy('createdAt');
    if (!isPremium) mockSetsQuery = mockSetsQuery.limit(2);

    final mockSetsSnapshot = await mockSetsQuery.get();

    for (final setDoc in mockSetsSnapshot.docs) {
      for (final batch in batches) {
        final query = await setDoc.reference
            .collection('questions')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        bookmarkedQuestions.addAll(
          query.docs.map((doc) => Question.fromMap(doc.id, doc.data())),
        );
      }
    }

    // =============================
    // 🔸 2. Handle Topics and Sets
    // =============================
    Query<Map<String, dynamic>> topicQuery =
        categoryRef.collection('topics').orderBy('createdAt');
    if (!isPremium) topicQuery = topicQuery.limit(2);

    final topicsSnapshot = await topicQuery.get();

    for (final topicDoc in topicsSnapshot.docs) {
      final topicRef = topicDoc.reference;

      // Limit sets for free users
      Query<Map<String, dynamic>> setsQuery =
          topicRef.collection('sets').orderBy('createdAt');
      if (!isPremium) setsQuery = setsQuery.limit(2);

      final setsSnapshot = await setsQuery.get();

      for (final setDoc in setsSnapshot.docs) {
        for (final batch in batches) {
          final query = await setDoc.reference
              .collection('questions')
              .where(FieldPath.documentId, whereIn: batch)
              .get();

          bookmarkedQuestions.addAll(
            query.docs.map((doc) => Question.fromMap(doc.id, doc.data())),
          );
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
      docRef.update(
          {'lastActive': DateTime.now().millisecondsSinceEpoch.toString()});
      return CustomUserModel.fromMap(doc.data()!);
    } else {
      // Create User
      final docRef = _db.collection("users").doc(userId);
      CustomUserModel user = CustomUserModel.fromMap({
        'id': userId,
        'isPremium': false,
        'bookmarks': [],
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
