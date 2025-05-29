import 'package:cbt_quiz_android/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question.dart';
import '../models/topic.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;

  static Future<bool> userExist() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  static Future<void> userSignOut() async {
    return (await auth.signOut());
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = UserModel(
      image: user.photoURL.toString(),
      name: user.displayName.toString(),
      about: "Hey I am using Happy Chat",
      createdAt: time,
      isOnline: false,
      lastActive: time,
      id: user.uid,
      email: user.email.toString(),
      pushToken: "",
    );
    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Topic>> getTopics(String category) async {
    final snapshot = await _db
        .collection('categories')
        .doc(category)
        .collection('topics')
        .get();

    return snapshot.docs
        .map((doc) => Topic.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Question>> getQuestions(String category, String topicId) async {
    final snapshot = await _db
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
    final topicsSnapshot = await _db
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
}
