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
      appBar: AppBar(title: Text('Topics')),
      body: Builder(
        builder: (_) {
          final topics = category == 'nursing' ? topicVM.nursingTopics : topicVM.midwiferyTopics;

          if (topics.isEmpty) {
            return Center(child: Text("No topics added yet."));
          }

          return GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16),
            childAspectRatio: 3,
            children: topics.map((topic) {
              return Card(
                child: ListTile(
                  title: Text(topic.name),
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
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
