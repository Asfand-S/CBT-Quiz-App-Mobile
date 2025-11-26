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
import 'view_model/theme_viewmodel.dart';
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

  runApp(MyApp1());
}

class MyApp1 extends StatelessWidget {
  const MyApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => UserViewModel()),
      ChangeNotifierProxyProvider<UserViewModel, TopicViewModel>(
        create: (_) => TopicViewModel(),
        update: (_, userViewModel, topicViewModel) =>
            topicViewModel!..setUserViewModel(userViewModel),
      ),
      ChangeNotifierProxyProvider<UserViewModel, SetViewModel>(
        create: (_) => SetViewModel(),
        update: (_, userViewModel, setViewModel) =>
            setViewModel!..setUserViewModel(userViewModel),
      ),
      ChangeNotifierProxyProvider<UserViewModel, QuizViewModel>(
        create: (_) => QuizViewModel(),
        update: (_, userViewModel, quizViewModel) =>
            quizViewModel!..setUserViewModel(userViewModel),
      ),
      ChangeNotifierProxyProvider<UserViewModel, QuestionViewModel>(
        create: (_) => QuestionViewModel(),
        update: (_, userViewModel, questionViewModel) =>
            questionViewModel!..setUserViewModel(userViewModel),
      ),
    ], child: const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: lightAppTheme,
          darkTheme: darkAppTheme,
          themeMode: themeProvider.themeMode,
          title: 'Quiz App',
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: '/',
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
