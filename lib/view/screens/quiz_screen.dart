import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/question.dart';
import '../../data/services/navigation_service.dart';
import '../../utils/Dialogs/dialog.dart';
import '../../view_model/question_viewmodel.dart';
import '../../view_model/user_viewmodel.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String? topicId;
  final String? topicName;
  final bool isMock;

  const QuizScreen({
    super.key,
    required this.category,
    this.topicId,
    this.topicName,
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
  final String explaination =
      "This is a dummy paragraph where the explaination will be showed only for the practice session have to check category then I have to print out the explaination";

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final qVM = Provider.of<QuestionViewModel>(context, listen: false);

    List<Question> fetched;

    if (widget.isMock) {
      fetched = await qVM.fetchQuestionsForCategory(widget.category);
    } else {
      fetched =
          await qVM.fetchQuestionsForTopic(widget.category, widget.topicId!);
    }

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
    final String message =
        await userVM.addBookmark(_questions[_currentIndex].id);

    Dialogs.snackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    if (_noQuestions) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isMock ? "Mock Quiz" : "Practice - ${widget.topicName}",
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
            widget.isMock ? "Mock Quiz" : "Practice - ${widget.topicName}",
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
            widget.isMock ? "Mock Quiz" : "Practice - ${widget.topicName}",
          ),
          actions: [
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Q${_currentIndex + 1}/${_questions.length}",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  q.question,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700),
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(q.options.length, (i) {
                Color buttonColor = Colors.teal; // Default color
                if (_selectedIndex != null && !widget.isMock) {
                  if (i == q.correctIndex) {
                    buttonColor = Colors.green.shade700; // Correct answer
                  } else if (i == _selectedIndex && i != q.correctIndex) {
                    buttonColor = Colors.red.shade700; // Incorrect answer
                  }
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(height: 10),
                Text(explaination, style: TextStyle(fontSize: 18)),
              ],
            ],
          ),
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
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.blue.withOpacity(0.4),
                      ),
                      child: const Text("Next"),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
