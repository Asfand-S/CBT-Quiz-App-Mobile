import 'package:cbt_quiz_android/data/models/question.dart';
import 'package:cbt_quiz_android/data/models/user.dart';
import 'package:cbt_quiz_android/data/services/firebase_service.dart';
import 'package:flutter/material.dart';

class BookmarkedQuestionsPage extends StatefulWidget {
  final String category;

  const BookmarkedQuestionsPage({super.key, required this.category});

  @override
  State<BookmarkedQuestionsPage> createState() =>
      _BookmarkedQuestionsPageState();
}

class _BookmarkedQuestionsPageState extends State<BookmarkedQuestionsPage> {
  late Future<List<Question>> _bookmarkedQuestionsFuture;

  @override
  void initState() {
    super.initState();
    _bookmarkedQuestionsFuture = _loadBookmarkedQuestions();
  }

  Future<List<Question>> _loadBookmarkedQuestions() async {
    // Step 1: Get current user profile
    UserModel? user = await FirebaseService().getCurrentUserProfile();

    if (user == null || user.bookmarks.isEmpty) return [];

    // Step 2: Fetch only bookmarked questions
    List<Question?> questions = await FirebaseService()
        .getAllBookmarkedQuestionsForCategory(
            widget.category, List<String>.from(user.bookmarks));

    // Filter out nulls
    return questions.whereType<Question>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Questions'),
      ),
      body: FutureBuilder<List<Question>>(
        future: _bookmarkedQuestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final questions = snapshot.data;

          if (questions == null || questions.isEmpty) {
            return const Center(child: Text('No bookmarked questions found.'));
          }

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return ListTile(
                title: Text(question.question),
                subtitle:
                    Text("Answer: ${question.options[question.correctIndex]}"),
              );
            },
          );
        },
      ),
    );
  }
}
