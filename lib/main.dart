import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/navigation_service.dart';
import 'view_model/quiz_viewmodel.dart';
import 'view_model/question_viewmodel.dart';
import 'view_model/topic_viewmodel.dart';
import 'firebase_options.dart';
import 'utils/routes.dart';
import 'view_model/useview_model.dart';

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
          ChangeNotifierProvider(create: (_) => UserViewModel()),
        ],
        child: MaterialApp(
            theme: ThemeData(
                appBarTheme: AppBarTheme(
                    titleTextStyle:
                        TextStyle(color: Colors.white, fontSize: 24),
                    iconTheme: IconThemeData(color: Colors.white))),
            title: 'Quiz App',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: '/',
            onGenerateRoute: onGenerateRoute));
  }
}
