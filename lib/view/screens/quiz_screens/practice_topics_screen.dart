import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/topic.dart';
import '../../../data/services/navigation_service.dart';
import '../../../utils/dialog.dart';
import '../../../utils/themes.dart';
import '../../../view_model/topic_viewmodel.dart';
import '../../../view_model/user_viewmodel.dart';

class PracticeTopicsScreen extends StatelessWidget {
  final String categoryId;

  const PracticeTopicsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final topicVM = Provider.of<TopicViewModel>(context);
    final userVM = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Topics'),
      ),
      body: FutureBuilder<List<(bool, Topic)>>(
        future: topicVM.fetchTopics(categoryId),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          final topics = snapshot.data ?? [];

          if (topics.isEmpty) return Center(child: Text("No topics added yet.", style: TextStyle(fontSize: 16, color: Colors.grey)));

          return GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16),
            childAspectRatio: 3,
            children: topics.map((record) {
              final (isLocked, topic) = record;

              return Card(
                elevation: 6,
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: isLocked
                  ? () {
                          Dialogs.snackBar(context,
                            'Locked – Upgrade to Access.');
                        }
                  : () {
                        if (!topicVM.currentUser.isPremium) {
                          if (categoryId.toLowerCase() == "nursing") { 
                            List<String> topicsIdList = topicVM.currentUser.unlockedTopicsNursing;
                            if (!topicsIdList.contains(topic.id)) {
                              topicsIdList.add(topic.id);
                              userVM.updateUserData('unlockedTopicsNursing', topicsIdList);
                            }
                          }
                          if (categoryId.toLowerCase() == "midwifery") { 
                            List<String> topicsIdList = topicVM.currentUser.unlockedTopicsMidwifery;
                            if (!topicsIdList.contains(topic.id)) {
                              topicsIdList.add(topic.id);
                              userVM.updateUserData('unlockedTopicsMidwifery', topicsIdList);
                            }
                          }
                        }
                    
                        // Navigate to quiz for this topic
                        NavigationService.navigateTo(
                          '/sets',
                          arguments: {
                            'categoryId': categoryId,
                            'topicId': topic.id,
                            'isMock': false,
                          },
                        );
                      },
                  child: Container(
                    decoration: gradientBackground,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          topic.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isLocked)
                          const Positioned(
                            right: 8,
                            top: 8,
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
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
