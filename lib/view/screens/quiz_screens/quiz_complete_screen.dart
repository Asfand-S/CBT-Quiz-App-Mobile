import 'package:cbt_quiz_android/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/navigation_service.dart';
import '../../../view_model/user_viewmodel.dart';

class QuizCompleteScreen extends StatelessWidget {
  final int score;
  final int total;
  final Duration timeTaken;
  final String setId;

  const QuizCompleteScreen({
    super.key,
    required this.score,
    required this.total,
    required this.timeTaken,
    required this.setId,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    final percent = ((score / total) * 100).toStringAsFixed(1);
    userViewModel.updatePassedQuizzes(setId, (score / total) * 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Completed'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "You scored $score out of $total",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Percentage: $percent%",
                      style:
                          const TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Time Taken: ${_formatDuration(timeTaken)}",
                      style:
                          const TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => NavigationService.pushReplacement('/home'),
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text(
                  "Back to Home",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: myTealShade,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
