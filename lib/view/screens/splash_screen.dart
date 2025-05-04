import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/navigation_service.dart';
import '../../view_model/topic_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TopicViewModel>(context, listen: false).fetchTopics();
    Future.delayed(Duration(seconds: 2), () {
      NavigationService.pushReplacement('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("QUIZ APP", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
