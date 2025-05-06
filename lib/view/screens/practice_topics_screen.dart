import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/navigation_service.dart';
import '../../view_model/topic_viewmodel.dart';

class PracticeTopicsScreen extends StatelessWidget {
  final String category;

  const PracticeTopicsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final topicVM = Provider.of<TopicViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: Builder(
        builder: (_) {
          final topics = category == 'nursing'
              ? topicVM.nursingTopics
              : topicVM.midwiferyTopics;

          if (topics.isEmpty) {
            return Center(
              child: Text(
                "No topics added yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16),
            childAspectRatio: 3,
            children: topics.map((topic) {
              return Card(
                elevation: 6,
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Navigate to quiz for this topic
                    NavigationService.navigateTo(
                      '/quiz',
                      arguments: {
                        'category': category,
                        'isMock': false,
                        'topicId': topic.id,
                        'topicName': topic.name,
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade300, Colors.teal.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        topic.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
