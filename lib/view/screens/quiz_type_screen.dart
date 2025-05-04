import 'package:flutter/material.dart';
import '../../data/services/navigation_service.dart';

class QuizTypeScreen extends StatelessWidget {
  final String category;

  const QuizTypeScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$category Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.menu_book),
              label: Text('Practice Quiz'),
              onPressed: () {
                NavigationService.navigateTo(
                  '/topics',
                  arguments: category,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.shuffle),
              label: Text('Mock Quiz'),
              onPressed: () {
                // Navigate to QuizScreen
                NavigationService.navigateTo(
                  '/quiz',
                  arguments: {
                    'category': category,
                    'isMock': true,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}