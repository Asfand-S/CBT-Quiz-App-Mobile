import 'package:cbt_quiz_android/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question.dart';
import '../models/topic.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static User? get user => auth.currentUser;

  static Future<bool> userExist() async {
    final currentUser = auth.currentUser;

    if (currentUser == null) return false;

    final doc = await firestore.collection("users").doc(currentUser.uid).get();
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
      isOnline: false,
      lastActive: time,
      id: currentUser.uid,
      email: currentUser.email ?? '',
      isPremium: false,
      pushToken: "",
      bookmarks: [],
    );
    return await firestore
        .collection("users")
        .doc(currentUser.uid)
        .set(chatUser.toMap());
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final currentUser = user;
      if (currentUser == null) return null;

      DocumentSnapshot doc =
          await firestore.collection('users').doc(currentUser.uid).get();

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

  Future<void> updateUserBookmarks(
      String userId, List<dynamic> bookmarks) async {
    await firestore.collection('users').doc(userId).update({
      'bookmarks': bookmarks,
    });
  }

  Future<List<Question?>> getBookmarkedQuestions(
      String category, List<dynamic> bookmarks) async {
    if (bookmarks.isEmpty) return [];

    final topicsSnapshot = await firestore
        .collection('categories')
        .doc(category)
        .collection('topics')
        .get();

    List<Question?> allQuestions = [];

    for (final topicDoc in topicsSnapshot.docs) {
      final questionsSnapshot =
          await topicDoc.reference.collection('questions').get();

      final questions = questionsSnapshot.docs.map((doc) {
        if (!bookmarks.contains(doc.id)) return null;
        return Question.fromMap(doc.id, doc.data());
      }).toList();

      allQuestions.addAll(questions);
    }

    return allQuestions;
  }

  Future<List<Topic>> getTopics(String category) async {
    final snapshot = await firestore
        .collection('categories')
        .doc(category)
        .collection('topics')
        .get();

    return snapshot.docs
        .map((doc) => Topic.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Question>> getQuestions(String category, String topicId) async {
    final snapshot = await firestore
        .collection('categories')
        .doc(category)
        .collection('topics')
        .doc(topicId)
        .collection('questions')
        .get();

    return snapshot.docs
        .map((doc) => Question.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Question>> getAllQuestionsForCategory(String category) async {
    final topicsSnapshot = await firestore
        .collection('categories')
        .doc(category)
        .collection('topics')
        .get();

    List<Question> allQuestions = [];

    for (final topicDoc in topicsSnapshot.docs) {
      final questionsSnapshot =
          await topicDoc.reference.collection('questions').get();

      final questions = questionsSnapshot.docs.map((doc) {
        return Question.fromMap(doc.id, doc.data());
      }).toList();

      allQuestions.addAll(questions);
    }

    return allQuestions;
  }

  Future<List<Question?>> getAllBookmarkedQuestionsForCategory(
      String category, List<String> bookmarks) async {
    final topicsSnapshot = await firestore
        .collection('categories')
        .doc(category)
        .collection('topics')
        .get();

    List<Question?> allQuestions = [];

    for (final topicDoc in topicsSnapshot.docs) {
      final questionsSnapshot =
          await topicDoc.reference.collection('questions').get();

      final questions = questionsSnapshot.docs.map((doc) {
        if (!bookmarks.contains(doc.id)) return null;
        return Question.fromMap(doc.id, doc.data());
      }).toList();

      allQuestions.addAll(questions);
    }

    return allQuestions;
  }
}
