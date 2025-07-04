import 'package:cbt_quiz_android/data/models/question.dart';
import 'package:cbt_quiz_android/data/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];

    // Step 2: Fetch only bookmarked questions
    List<Question?> questions = await FirebaseService()
        .getBookmarkedQuestions(widget.category, List<String>.from(bookmarks));

    // Filter out nulls
    return questions.whereType<Question>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarked Questions',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 187, 226, 223),
              const Color.fromARGB(255, 183, 218, 214),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Question>>(
          future: _bookmarkedQuestionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.teal.shade700,
                  strokeWidth: 6,
                  backgroundColor: Colors.teal.shade100,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.teal.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final questions = snapshot.data;

            if (questions == null || questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 60,
                      color: Colors.teal.shade700,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarked questions found.',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade100, Colors.teal.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Answer: ${question.options[question.correctIndex]}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.bookmark,
                        color: Colors.teal.shade700,
                        size: 28,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
