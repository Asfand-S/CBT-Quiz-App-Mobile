import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/navigation_service.dart';
import 'view_model/quiz_viewmodel.dart';
import 'view_model/question_viewmodel.dart';
import 'view_model/topic_viewmodel.dart';
import 'firebase_options.dart';
import 'utils/routes.dart';


 late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TopicViewModel()),
        ChangeNotifierProvider(create: (_) => QuizViewModel()),
        ChangeNotifierProvider(create: (_) => QuestionViewModel()),
      ],
      child: MaterialApp(
        title: 'Quiz App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        onGenerateRoute: onGenerateRoute
      )
    );
  }
}
