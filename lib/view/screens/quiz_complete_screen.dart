import 'package:flutter/material.dart';
import '../../data/services/navigation_service.dart';

class QuizCompleteScreen extends StatelessWidget {
  final int score;
  final int total;
  final Duration timeTaken;

  const QuizCompleteScreen({
    super.key,
    required this.score,
    required this.total,
    required this.timeTaken,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final percent = ((score / total) * 100).toStringAsFixed(1);

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
              const Text("🎉", style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text("You scored $score out of $total",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Percentage: $percent%",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text("Time Taken: ${_formatDuration(timeTaken)}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => NavigationService.pushReplacement('/home'),
                icon: const Icon(Icons.home),
                label: const Text("Back to Home"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
