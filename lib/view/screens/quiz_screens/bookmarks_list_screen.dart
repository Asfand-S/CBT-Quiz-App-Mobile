import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/question.dart';
import '../../../data/services/navigation_service.dart';
import '../../../utils/themes.dart';
import '../../../view_model/user_viewmodel.dart';

class BookmarksPage extends StatefulWidget {
  final String categoryId;

  const BookmarksPage({super.key, required this.categoryId});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  void initState() {
    super.initState();
    _loadBookmarkedQuestions();
  }

  Future<List<Question>> _loadBookmarkedQuestions() async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    final questions = await userVM.getBookmarkedQuestions(widget.categoryId);

    // Filter out nulls
    return questions.whereType<Question>().toList();
  }

  Future<void> _removeBookmark(BuildContext context, String questionId) async {
    // confirm before removing the bookmark
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to remove this bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final userVM = Provider.of<UserViewModel>(context, listen: false);
    await userVM.removeBookmark(questionId, widget.categoryId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Questions')),
      body: FutureBuilder<List<Question>>(
        future: _loadBookmarkedQuestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
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
                    color: myTealShade,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      fontSize: 18,
                      color: myTealShade,
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
                    color: myTealShade,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarked questions found.',
                    style: TextStyle(
                      fontSize: 20,
                      color: myTealShade,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            );
          }
      
          return ListView.builder(
            padding: const EdgeInsets.all(6),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: Colors.teal.shade50,
                  title: Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Answer: ${question.options[question.correctIndex]}",
                      style: TextStyle(
                        fontSize: 16,
                        color: myTealShade,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => _removeBookmark(context, question.id),
                    icon: Icon(
                      Icons.bookmark_remove,
                      color: myTealShade,
                      size: 30,
                    ),
                  ),
                  onTap:() async {
                    final result = await NavigationService.navigateTo(
                      '/question',
                      arguments: {
                        'categoryId': widget.categoryId,
                        'question': question
                      },
                    );
      
                    if (result == true) {
                      setState(() {_loadBookmarkedQuestions();});
                    }
                  }
                ),
              );
            },
          );
        },
      ),
    );
  }
}
