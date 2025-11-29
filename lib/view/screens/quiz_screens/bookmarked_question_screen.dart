import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/question.dart';
import '../../../utils/themes.dart';
import '../../../view_model/user_viewmodel.dart';

class QuestionScreen extends StatelessWidget {
  final Question question;
  final String categoryId;

  const QuestionScreen({super.key, required this.question, required this.categoryId});

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
    userVM.removeBookmark(questionId, categoryId);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bookmark",
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bookmark_remove,
              color: Colors.white,
            ),
            onPressed: () async {
              await _removeBookmark(context, question.id);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.question,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: myTealShade),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(question.options.length, (i) {
                    Color buttonColor = myTealShade; // Default color
                    if (i == question.correctIndex) {
                      buttonColor = Colors.green.shade600; // Correct answer
                    } else {
                      buttonColor = myTealShade;
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: buttonColor,
                          disabledBackgroundColor:
                              buttonColor, // Maintain color when disabled
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () => {},
                        child: Text(
                          question.options[i],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 10),
                  Text("Explanation",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(question.explanation, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
