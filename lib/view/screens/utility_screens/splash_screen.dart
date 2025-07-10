import 'package:cbt_quiz_android/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/navigation_service.dart';
import '../../../view_model/user_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserViewModel>(context, listen: false).init();
    userCheck();
  }

  void userCheck() async {
    await Future.delayed(Duration(seconds: 2), () {
      NavigationService.pushReplacement('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Nursing CBT NG",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: myTealShade)),
      ),
    );
  }
}
