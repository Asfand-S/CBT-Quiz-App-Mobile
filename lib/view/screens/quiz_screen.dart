import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/question.dart';
import '../../data/services/navigation_service.dart';
import '../../view_model/question_viewmodel.dart';

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
  int _currentIndex = 0;
  int _score = 0;
  late DateTime _startTime;

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
      fetched.shuffle();
    } else {
      fetched = await qVM.fetchQuestionsForTopic(widget.category, widget.topicId!);
    }

    setState(() {
      _questions = fetched;
    });
  }

  void _submitAnswer(int selectedIndex) {
    final current = _questions[_currentIndex];
    if (selectedIndex == current.correctIndex) _score++;

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
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

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isMock
            ? "Mock Quiz"
            : "Practice - ${widget.topicName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Q${_currentIndex + 1}/${_questions.length}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(q.question, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            ...List.generate(q.options.length, (i) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () => _submitAnswer(i),
                  child: Text(q.options[i]),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
