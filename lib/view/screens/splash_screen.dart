import 'package:cbt_quiz_android/data/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/navigation_service.dart';
import '../../view_model/topic_viewmodel.dart';
import '../../view_model/useview_model.dart';

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
    Provider.of<UserViewModel>(context, listen: false).loadUser();
    userCheck();
  }

  void userCheck() async {
    if (await FirebaseService.userExist()) {
      await Future.delayed(Duration(seconds: 2), () {
        NavigationService.pushReplacement('/home');
      });
    } else {
      await Future.delayed(Duration(seconds: 2), () {
        NavigationService.pushReplacement('/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("QUIZ APP",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
