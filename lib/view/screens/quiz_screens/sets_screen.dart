import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/set.dart';
import '../../../data/services/navigation_service.dart';
import '../../../utils/themes.dart';
import '../../../view_model/set_viewmodel.dart';

class SetsScreen extends StatelessWidget {
  final String categoryId;
  final String topicId;
  final bool isMock;

  const SetsScreen({
    super.key, 
    required this.categoryId,
    required this.topicId,
    required this.isMock
    });

  @override
  Widget build(BuildContext context) {
    final setVM = Provider.of<SetViewModel>(context);
    String titleText = "Practice Quiz Sets";
    if (isMock) {
      titleText = "Mock Quiz Sets";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: FutureBuilder<List<Set>>(
        future: setVM.fetchSets(categoryId, topicId),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          final sets = snapshot.data ?? [];

          if (sets.isEmpty) return Center(child: Text("No quiz sets added yet.", style: TextStyle(fontSize: 16, color: Colors.grey)));

          return GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(16),
            childAspectRatio: 3,
            children: sets.map((set) {
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
                        'categoryId': categoryId,
                        'topicId': topicId,
                        'setId': set.id,
                        'setName': set.name,
                        'isMock': isMock,
                      },
                    );
                  },
                  child: Container(
                    decoration: gradientBackground,
                    child: Center(
                      child: Text(
                        set.name,
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
