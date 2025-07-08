import 'package:cbt_quiz_android/data/models/question.dart';
import 'package:cbt_quiz_android/view/screens/utility_screens/aboutus_screen.dart';
import 'package:flutter/material.dart';
import '../view/screens/quiz_screens/bookmarked_question_screen.dart';
import '../view/screens/quiz_screens/sets_screen.dart';
import '../view/screens/utility_screens/splash_screen.dart';
import '../view/screens/quiz_screens/home_screen.dart';
import '../view/screens/quiz_screens/quiz_type_screen.dart';
import '../view/screens/quiz_screens/practice_topics_screen.dart';
import '../view/screens/quiz_screens/quiz_screen.dart';
import '../view/screens/quiz_screens/quiz_complete_screen.dart';
import '../view/screens/utility_screens/payment_screen.dart';
import '../view/screens/quiz_screens/bookmarks_list_screen.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => SplashScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => HomeScreen());
    case '/premium':
      return MaterialPageRoute(builder: (_) => PremiumScreen());
    case '/aboutus':
      return MaterialPageRoute(builder: (_) => AboutUsPage());

    case '/bookmarks':
      final args = settings.arguments as String;
      return MaterialPageRoute(builder: (_) => BookmarksPage(categoryId: args));

    case '/question':
      final args = settings.arguments as Question;
      return MaterialPageRoute(builder: (_) => QuestionScreen(question: args));

    case '/quizType':
      final args = settings.arguments as String; // category
      return MaterialPageRoute(
        builder: (_) => QuizTypeScreen(categoryId: args),
      );

    case '/topics':
      final args = settings.arguments as String; // category
      return MaterialPageRoute(
        builder: (_) => PracticeTopicsScreen(categoryId: args),
      );

    case '/sets':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => SetsScreen(
          categoryId: args['categoryId'],
          topicId: args['topicId'],
          isMock: args['isMock'],
        ),
      );

    case '/quiz':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => QuizScreen(
          categoryId: args['categoryId'],
          topicId: args['topicId'],
          setId: args['setId'],
          setName: args['setName'],
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
          setId: args['setId'],
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
