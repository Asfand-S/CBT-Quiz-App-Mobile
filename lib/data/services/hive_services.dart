import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic.dart';
import '../models/question.dart';

class HiveService {
  static const String _metadataBox = 'metadataBox';
  static const String _boxName = 'categoriesBox';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> ensureLocalData() async {
    final box = await Hive.openBox<Map>(_boxName);

    if (box.isEmpty) {
      print("\n\n\n📦 Hive box is empty. Downloading all data from Firestore...");
      await _downloadAllDataFromFirestore();
    } else {
      print("\n\n\n📦 Hive box has data. Syncing updates...");
      await syncDataFromFirebase();
    }
  }

  Future<void> _downloadAllDataFromFirestore() async {
    final box = await Hive.openBox<Map>(_boxName);
    final metadataBox = await Hive.openBox(_metadataBox);

    final categorySnap = await FirebaseFirestore.instance.collection('categories').get();

    for (final catDoc in categorySnap.docs) {
      final categoryId = catDoc.id;
      final categoryUpdated = (catDoc.data()['lastUpdated'] as Timestamp?)?.toDate();

      final topicsSnap = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('topics')
          .get();

      final categoryMap = <String, Map<String, dynamic>>{};

      for (final topicDoc in topicsSnap.docs) {
        final topicId = topicDoc.id;
        final topicData = Topic.fromMap(topicId, topicDoc.data());

        final questionsSnap = await FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('topics')
            .doc(topicId)
            .collection('questions')
            .get();

        final questions = questionsSnap.docs
            .map((q) => Question.fromMap(q.id, q.data()))
            .toList();

        categoryMap[topicId] = {
          'topic': topicData,
          'questions': questions,
        };

        // Save topic-level lastUpdated
        final topicUpdated = (topicDoc.data()['lastUpdated'] as Timestamp?)?.toDate();
        if (topicUpdated != null) {
          metadataBox.put('topic_${categoryId}_$topicId', topicUpdated);
        }
      }

      await box.put(categoryId, categoryMap);

      // Save category-level lastUpdated
      if (categoryUpdated != null) {
        metadataBox.put('cat_$categoryId', categoryUpdated);
      }

      print("✅ Downloaded and stored category: $categoryId");
    }
  }

  Future<void> syncDataFromFirebase() async {
    final categoriesBox = await Hive.openBox<Map>(_boxName);
    final metadataBox = await Hive.openBox(_metadataBox);

    final categoriesSnap = await _db.collection('categories').get();

    for (var catDoc in categoriesSnap.docs) {
      final categoryId = catDoc.id;
      final categoryUpdated = (catDoc.data()['lastUpdated'] as Timestamp?)?.toDate();
      final localCatUpdated = metadataBox.get('cat_$categoryId') as DateTime?;

      final categoryMap = <String, dynamic>{};

      if (categoryUpdated != null && (localCatUpdated == null || categoryUpdated.isAfter(localCatUpdated))) {
        // Entire category needs to be re-downloaded
        print("📦 Re-downloading category: $categoryId");
        final topicsSnap = await _db.collection('categories').doc(categoryId).collection('topics').get();

        for (var topicDoc in topicsSnap.docs) {
          final topicId = topicDoc.id;
          final topic = Topic.fromMap(topicId, topicDoc.data());

          final questionsSnap = await _db
              .collection('categories')
              .doc(categoryId)
              .collection('topics')
              .doc(topicId)
              .collection('questions')
              .get();

          final questions = questionsSnap.docs
              .map((qDoc) => Question.fromMap(qDoc.id, qDoc.data()))
              .toList();

          categoryMap[topicId] = {
            'topic': topic,
            'questions': questions,
          };

          metadataBox.put('topic_${categoryId}_$topicId', topic.lastUpdated);
        }

        await categoriesBox.put(categoryId, categoryMap);
        metadataBox.put('cat_$categoryId', categoryUpdated);

      } else {
        print("📦 Syncing category: $categoryId");
        // Check and update individual topics
        final categoryMap = categoriesBox.get(categoryId) ?? {};

        final topicsSnap = await _db.collection('categories').doc(categoryId).collection('topics').get();

        for (var topicDoc in topicsSnap.docs) {
          final topicId = topicDoc.id;
          final topicUpdated = (topicDoc.data()['lastUpdated'] as Timestamp?)?.toDate();
          final localTopicUpdated = metadataBox.get('topic_${categoryId}_$topicId') as DateTime?;

          if (topicUpdated != null && (localTopicUpdated == null || topicUpdated.isAfter(localTopicUpdated))) {
            print("📘 Syncing topic: ${topicDoc.data()['name']}");
            final topic = Topic.fromMap(topicId, topicDoc.data());

            final questionsSnap = await _db
                .collection('categories')
                .doc(categoryId)
                .collection('topics')
                .doc(topicId)
                .collection('questions')
                .get();

            final questions = questionsSnap.docs
                .map((qDoc) => Question.fromMap(qDoc.id, qDoc.data()))
                .toList();

            categoryMap[topicId] = {
              'topic': topic,
              'questions': questions,
            };

            metadataBox.put('topic_${categoryId}_$topicId', topicUpdated);
          }
        }

        await categoriesBox.put(categoryId, categoryMap);
      }
    }
  }



  Future<List<Topic>> getTopics(String categoryId) async {
    final box = await Hive.openBox<Map>(_boxName);
    final categoryMap = box.get(categoryId);

    if (categoryMap == null) {
      return [];
    }

    final topics = categoryMap.values
        .map((entry) => entry['topic'] as Topic)
        .toList();

    return topics;
  }

  Future<List<Question>> getQuestionsForTopic(String categoryId, String topicId) async {
    final box = await Hive.openBox<Map>('categoriesBox');
    final categoryMap = box.get(categoryId);

    if (categoryMap == null || categoryMap[topicId] == null) return [];

    final questions = List<Question>.from(categoryMap[topicId]['questions']);
    return questions;
  }

  Future<List<Question>> getAllQuestionsForCategory(String categoryId) async {
    final box = await Hive.openBox<Map>('categoriesBox');
    final categoryMap = box.get(categoryId);

    if (categoryMap == null) return [];

    final allQuestions = <Question>[];
    for (final topicEntry in categoryMap.values) {
      final questions = List<Question>.from(topicEntry['questions']);
      allQuestions.addAll(questions);
    }

    return allQuestions;
  }

  Future<List<Question>> getBookmarkedQuestions(
    String categoryId,
    List<String> bookmarks,
  ) async {
    final box = await Hive.openBox<Map>('categoriesBox');
    final categoryMap = box.get(categoryId);

    if (categoryMap == null) return [];

    final bookmarked = <Question>[];
    for (final topicEntry in categoryMap.values) {
      final questions = List<Question>.from(topicEntry['questions']);
      bookmarked.addAll(questions.where((q) => bookmarks.contains(q.id)));
    }

    return bookmarked;
  }

  Future<void> printLocalDataSummary() async {
    final categoryBox = await Hive.openBox<Map>('categoriesBox');

    print('📦 Local Data Summary:\n');

    for (var categoryKey in categoryBox.keys) {
      final category = categoryKey as String;
      print('🗂️ Category: $category');

      final topicsMap = categoryBox.get(category);
      if (topicsMap == null) continue;

      for (var topicId in topicsMap.keys) {
        final topicData = topicsMap[topicId] as Map?;

        if (topicData == null) continue;

        final topicName = topicData['topic'] is Topic
            ? (topicData['topic'] as Topic).name
            : 'Unknown';
        final questionsRaw = topicData['questions'] as List<dynamic>? ?? [];
        final questions = questionsRaw.whereType<Question>().toList();

        print('  📘 Topic: $topicName (${questions.length} questions)');
      }
      print(''); // Add spacing between categories
    }
  }

}
