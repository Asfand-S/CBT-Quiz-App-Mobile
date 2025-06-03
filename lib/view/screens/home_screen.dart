import 'package:cbt_quiz_android/data/services/firebase_service.dart';
import 'package:cbt_quiz_android/view/screens/bookmark_questions.dart';
import 'package:flutter/material.dart';
import '../../data/services/navigation_service.dart';

class HomeScreen extends StatelessWidget {
  final List<String> categories = ['nursing', 'midwifery'];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category'),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseService.userSignOut();
                NavigationService.navigateTo('/login');
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 1,
        childAspectRatio: 1.5,
        children: categories.map((cat) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            margin: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => NavigationService.navigateTo(
                '/quizType',
                arguments: cat,
              ),
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
                    cat.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Row(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookmarkedQuestionsPage(
                              category: 'nursing',
                            )));
              },
              child: Text("bookmark"))
        ],
      ),
    );
  }
}
