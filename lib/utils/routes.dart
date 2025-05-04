import 'package:flutter/material.dart';
import '../view/screens/splash_screen.dart';
import '../view/screens/home_screen.dart';
import '../view/screens/quiz_type_screen.dart';
import '../view/screens/practice_topics_screen.dart';
import '../view/screens/quiz_screen.dart';
import '../view/screens/quiz_complete_screen.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => SplashScreen());

    case '/home':
      return MaterialPageRoute(builder: (_) => HomeScreen());

    case '/quizType':
      final args = settings.arguments as String; // category
      return MaterialPageRoute(
        builder: (_) => QuizTypeScreen(category: args),
      );

    case '/topics':
      final args = settings.arguments as String; // category
      return MaterialPageRoute(
        builder: (_) => PracticeTopicsScreen(category: args),
      );

    case '/quiz':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => QuizScreen(
          category: args['category'],
          topicId: args['topicId'],
          topicName: args['topicName'],
          isMock: args['isMock'],
        ),
      );

    case '/complete':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => QuizCompleteScreen(
          score: args['score']!,
          total: args['total']!,
          timeTaken: args['timeTaken']!,
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
