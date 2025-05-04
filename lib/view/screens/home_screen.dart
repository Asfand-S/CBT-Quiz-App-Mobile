import 'package:flutter/material.dart';
import '../../data/services/navigation_service.dart';

class HomeScreen extends StatelessWidget {
  final List<String> categories = ['nursing', 'midwifery'];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Category')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        children: categories.map((cat) {
          return Card(
            child: InkWell(
              onTap: () => NavigationService.navigateTo(
                  '/quizType',
                  arguments: cat,
                ),
              child: Center(child: Text(cat.toUpperCase(), style: TextStyle(fontSize: 18))),
            ),
          );
        }).toList(),
      ),
    );
  }
}
