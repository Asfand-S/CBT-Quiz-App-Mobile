import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'data/models/topic.dart';
import 'data/models/set.dart';
import 'data/models/question.dart';
import 'data/services/navigation_service.dart';
import 'view_model/quiz_viewmodel.dart';
import 'view_model/question_viewmodel.dart';
import 'view_model/set_viewmodel.dart';
import 'view_model/user_viewmodel.dart';
import 'view_model/topic_viewmodel.dart';
import 'utils/routes.dart';
import 'utils/themes.dart';

late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  Hive.registerAdapter(TopicAdapter());
  Hive.registerAdapter(SetAdapter());
  Hive.registerAdapter(QuestionAdapter());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TopicViewModel()),
          ChangeNotifierProvider(create: (_) => SetViewModel()),
          ChangeNotifierProvider(create: (_) => QuizViewModel()),
          ChangeNotifierProvider(create: (_) => QuestionViewModel()),
          ChangeNotifierProvider(create: (_) => UserViewModel()),
        ],
        child: MaterialApp(
            theme: appTheme,
            title: 'Quiz App',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            initialRoute: '/',
            onGenerateRoute: onGenerateRoute));
  }
}
