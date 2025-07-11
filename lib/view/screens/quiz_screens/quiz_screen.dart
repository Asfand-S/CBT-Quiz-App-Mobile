import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/question.dart';
import '../../../data/services/navigation_service.dart';
import '../../../utils/dialog.dart';
import '../../../utils/themes.dart';
import '../../../view_model/question_viewmodel.dart';
import '../../../view_model/user_viewmodel.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String topicId;
  final String setId;
  final String setName;
  final bool isMock;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.topicId,
    required this.setId,
    required this.setName,
    required this.isMock,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  bool _noQuestions = false;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex; // Track the selected answer
  late DateTime _startTime;
  Timer? _quizTimer;
  Duration _remainingTime = Duration(minutes: 20);

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadQuestions();

    if (widget.isMock) {
      _startQuizTimer();
    }
  }

  void _startQuizTimer() {
    _quizTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _remainingTime - Duration(seconds: 1);

        if (_remainingTime.inSeconds <= 0) {
          timer.cancel();
          final duration = DateTime.now().difference(_startTime);

          // Navigate to completion and clear backstack
          NavigationService.navigateTo(
            '/complete',
            arguments: {
              'score': _score,
              'total': _questions.length,
              'timeTaken': duration,
              'setId': widget.setId,
            },
          );
        }
      });
    });
  }

  Future<void> _loadQuestions() async {
    final qVM = Provider.of<QuestionViewModel>(context, listen: false);

    List<Question> fetched = await qVM.fetchQuestions(
        widget.categoryId, widget.topicId, widget.setId);

    setState(() {
      _questions = fetched;
      _noQuestions = fetched.isEmpty;
    });
  }

  void _submitAnswer(int selectedIndex) {
    setState(() {
      _selectedIndex = selectedIndex; // Store the selected index
    });

    final current = _questions[_currentIndex];
    if (selectedIndex == current.correctIndex) {
      _score++;
    }

    if (widget.isMock) {
      // For mock mode, proceed to next question immediately
      _nextQuestion();
    } else {
      // For practice mode, show explanation and wait for user to press Next
      setState(() {});
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null; // Reset selected index for the next question
      });
    } else {
      final duration = DateTime.now().difference(_startTime);

      // Navigate to completion and clear backstack
      NavigationService.navigateTo(
        '/complete',
        arguments: {
          'score': _score,
          'total': _questions.length,
          'timeTaken': duration,
          'setId': widget.setId,
        },
      );
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quit Quiz'),
          content: const Text('Are you sure you want to quit the quiz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User doesn't want to quit
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User wants to quit
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return shouldPop ?? false;
  }

  Future<void> _bookmarkQuestion() async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    List<String> bookmarks = userVM.currentUser.bookmarks;
    String message = "";

    final questionId = _questions[_currentIndex].id;
    if (bookmarks.contains(questionId)) {
      message = "Question already bookmarked.";
    } else if (!(userVM.currentUser.isPremium) && bookmarks.length >= 5) {
      message = "You can only bookmark 5 questions.";
    } else {
      bookmarks.add(questionId);
      await userVM.updateUserData("bookmarks", bookmarks);
      message = "Bookmark added successfully.";
    }

    Dialogs.snackBar(context, message);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_noQuestions) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isMock ? "Mock Quiz" : "Practice - ${widget.setName}",
            ),
          ),
          body: Center(
            child: Text(
              "No questions added yet.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ));
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isMock ? "Mock Quiz" : "Practice - ${widget.setName}",
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _questions[_currentIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isMock ? "Mock Quiz" : "Practice - ${widget.setName}",
          ),
          actions: widget.isMock
              ? []
              : [
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await _bookmarkQuestion();
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Q${_currentIndex + 1}/${_questions.length}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        // Right: Timer display
                        Text(
                          _formatDuration(_remainingTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        q.question,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: myTealShade),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(q.options.length, (i) {
                      Color buttonColor = myTealShade; // Default color
                      if (_selectedIndex != null && !widget.isMock) {
                        if (i == q.correctIndex) {
                          buttonColor = Colors.green.shade600; // Correct answer
                        } else if (i == _selectedIndex && i != q.correctIndex) {
                          buttonColor = Colors.red.shade600; // Incorrect answer
                        }
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
                          onPressed: _selectedIndex == null
                              ? () => _submitAnswer(i)
                              : null, // Disable button after selection
                          child: Text(
                            q.options[i],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
                    if (!widget.isMock && _selectedIndex != null) ...[
                      SizedBox(height: 10),
                      Text("Explanation",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(q.explanation, style: TextStyle(fontSize: 16)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.isMock || _selectedIndex == null
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        backgroundColor: Colors.teal.shade500,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Next"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _quizTimer?.cancel();
    super.dispose();
  }
}
