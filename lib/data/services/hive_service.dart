import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/topic.dart';
import '../models/set.dart';
import '../models/question.dart';

class HiveService {
  static const String _metadataBox = 'metadataBox';
  static const String _boxName = 'categoriesBox';

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> ensureLocalQuizData() async {
    final box = await Hive.openBox<Map>(_boxName);

    if (box.isEmpty) {
      print(
          "\n\n\n📦 Hive box is empty. Downloading all data from Firestore...");
      await _downloadAllDataFromFirestore();
    } else {
      print("\n\n\n📦 Hive box has data. Syncing updates...");
      await syncDataFromFirebase();
    }
  }

  Future<void> _downloadAllDataFromFirestore() async {
    final box = await Hive.openBox<Map>(_boxName);
    final metadataBox = await Hive.openBox(_metadataBox);

    final categorySnap = await _db.collection('categories').get();

    for (final catDoc in categorySnap.docs) {
      final categoryId = catDoc.id;
      final categoryUpdated =
          (catDoc.data()['lastUpdated'] as Timestamp?)?.toDate();

      final categoryMap = <String, dynamic>{
        'topics': {},
        'mock_sets': {},
      };

      // Topics & Sets
      final topicsSnap = await _db
          .collection('categories')
          .doc(categoryId)
          .collection('topics')
          .get();

      for (final topicDoc in topicsSnap.docs) {
        final topicId = topicDoc.id;
        final topicData = Topic.fromMap(topicId, topicDoc.data());

        final setsSnap = await _db
            .collection('categories')
            .doc(categoryId)
            .collection('topics')
            .doc(topicId)
            .collection('sets')
            .get();

        final Map<String, dynamic> topicMap = {
          'topic': topicData,
          'sets': {},
        };

        for (final setDoc in setsSnap.docs) {
          final setId = setDoc.id;
          final setData = setDoc.data();
          final setName = setData['name'] as String? ?? 'Set';

          final questionsSnap = await _db
              .collection('categories')
              .doc(categoryId)
              .collection('topics')
              .doc(topicId)
              .collection('sets')
              .doc(setId)
              .collection('questions')
              .get();

          final questions = questionsSnap.docs
              .map((q) => Question.fromMap(q.id, q.data()))
              .toList();

          topicMap['sets'][setId] = {
            'setName': setName,
            'questions': questions,
          };

          final setUpdated = (setData['lastUpdated'] as Timestamp?)?.toDate();
          if (setUpdated != null) {
            metadataBox.put(
                'topic_${categoryId}_${topicId}_$setId', setUpdated);
          }
        }

        categoryMap['topics'][topicId] = topicMap;

        final topicUpdated =
            (topicDoc.data()['lastUpdated'] as Timestamp?)?.toDate();
        if (topicUpdated != null) {
          metadataBox.put('topic_${categoryId}_$topicId', topicUpdated);
        }
      }

      // Mock Sets
      final mockSetsSnap = await _db
          .collection('categories')
          .doc(categoryId)
          .collection('mock_sets')
          .get();
      for (final mockDoc in mockSetsSnap.docs) {
        final setId = mockDoc.id;
        final setData = mockDoc.data();
        final setName = setData['name'] as String? ?? 'Mock';

        final questionsSnap = await _db
            .collection('categories')
            .doc(categoryId)
            .collection('mock_sets')
            .doc(setId)
            .collection('questions')
            .get();

        final questions = questionsSnap.docs
            .map((q) => Question.fromMap(q.id, q.data()))
            .toList();

        categoryMap['mock_sets'][setId] = {
          'setName': setName,
          'questions': questions,
        };

        final mockUpdated = (setData['lastUpdated'] as Timestamp?)?.toDate();
        if (mockUpdated != null) {
          metadataBox.put('mock_${categoryId}_$setId', mockUpdated);
        }
      }

      await box.put(categoryId, categoryMap);
      if (categoryUpdated != null) {
        metadataBox.put('cat_$categoryId', categoryUpdated);
      }
      print("✅ Downloaded and stored category: $categoryId");
    }
  }

  Future<void> syncDataFromFirebase() async {
    final box = await Hive.openBox<Map>(_boxName);
    final metadataBox = await Hive.openBox(_metadataBox);

    final categorySnap = await _db.collection('categories').get();

    for (final catDoc in categorySnap.docs) {
      final categoryId = catDoc.id;
      final categoryUpdated =
          (catDoc.data()['lastUpdated'] as Timestamp?)?.toDate();
      final localCategoryUpdated =
          metadataBox.get('cat_$categoryId') as DateTime?;

      final currentCategoryMap = box.get(categoryId.toLowerCase()) ??
          {
            'topics': {},
            'mock_sets': {},
          };

      if (categoryUpdated != null &&
          (localCategoryUpdated == null ||
              categoryUpdated.isAfter(localCategoryUpdated))) {
        print("📦 Re-downloading full category: $categoryId");
        await _downloadAllDataFromFirestore();
        return;
      }

      // Sync topic sets
      final topicsSnap = await _db
          .collection('categories')
          .doc(categoryId)
          .collection('topics')
          .get();
      for (final topicDoc in topicsSnap.docs) {
        final topicId = topicDoc.id;
        final topicData = Topic.fromMap(topicId, topicDoc.data());

        final setsSnap = await _db
            .collection('categories')
            .doc(categoryId)
            .collection('topics')
            .doc(topicId)
            .collection('sets')
            .get();

        currentCategoryMap['topics'] ??= {};
        final topicMap = currentCategoryMap['topics'][topicId] ??
            {
              'topic': topicData,
              'sets': {},
            };

        for (final setDoc in setsSnap.docs) {
          final setId = setDoc.id;
          final setData = setDoc.data();
          final setUpdated = (setData['lastUpdated'] as Timestamp?)?.toDate();
          final localSetUpdated = metadataBox
              .get('topic_${categoryId}_${topicId}_$setId') as DateTime?;

          if (setUpdated != null &&
              (localSetUpdated == null ||
                  setUpdated.isAfter(localSetUpdated))) {
            print("📘 Syncing topic set: $categoryId/$topicId/$setId");
            final questionsSnap = await _db
                .collection('categories')
                .doc(categoryId)
                .collection('topics')
                .doc(topicId)
                .collection('sets')
                .doc(setId)
                .collection('questions')
                .get();

            final questions = questionsSnap.docs
                .map((q) => Question.fromMap(q.id, q.data()))
                .toList();
            topicMap['sets'][setId] = {
              'setName': setData['name'] ?? 'Set',
              'questions': questions,
            };

            metadataBox.put(
                'topic_${categoryId}_${topicId}_$setId', setUpdated);
          }
        }

        currentCategoryMap['topics'][topicId] = topicMap;
        metadataBox.put('topic_${categoryId}_$topicId', topicData.lastUpdated);
      }

      // Sync mock sets
      final mockSetsSnap = await _db
          .collection('categories')
          .doc(categoryId)
          .collection('mock_sets')
          .get();
      currentCategoryMap['mock_sets'] ??= {};

      for (final mockDoc in mockSetsSnap.docs) {
        final setId = mockDoc.id;
        final setData = mockDoc.data();
        final setUpdated = (setData['lastUpdated'] as Timestamp?)?.toDate();
        final localSetUpdated =
            metadataBox.get('mock_${categoryId}_$setId') as DateTime?;

        if (setUpdated != null &&
            (localSetUpdated == null || setUpdated.isAfter(localSetUpdated))) {
          print("🧪 Syncing mock set: $categoryId/$setId");
          final questionsSnap = await _db
              .collection('categories')
              .doc(categoryId)
              .collection('mock_sets')
              .doc(setId)
              .collection('questions')
              .get();

          final questions = questionsSnap.docs
              .map((q) => Question.fromMap(q.id, q.data()))
              .toList();

          currentCategoryMap['mock_sets'][setId] = {
            'setName': setData['name'] ?? 'Mock',
            'questions': questions,
          };

          metadataBox.put('mock_${categoryId}_$setId', setUpdated);
        }
      }

      await box.put(categoryId, currentCategoryMap);
    }
  }

  Future<List<Topic>> getTopics(String categoryId) async {
    final box = await Hive.openBox<Map>(_boxName);
    final categoryMap = box.get(categoryId.toLowerCase());
    if (categoryMap == null || categoryMap['topics'] == null) return [];

    final topicsMap = categoryMap['topics'] as Map;
    return topicsMap.values.map((e) => e['topic'] as Topic).toList();
  }

  Future<List<Set>> getSets(
      String categoryId, String topicId, List<String> passedQuizzes) async {
    final box = await Hive.openBox<Map>(_boxName);
    final categoryMap = box.get(categoryId.toLowerCase());
    if (categoryMap == null) return [];

    if (topicId.isEmpty) {
      // Return mock sets
      final mockSetsMap = categoryMap['mock_sets'] as Map?;
      if (mockSetsMap == null) return [];

      List<Set> setsOpened = [];
      // BEFORE
      // for (final entry in mockSetsMap.entries) {
      //   final setId = entry.key.toString();
      //   if (passedQuizzes.contains(setId)) {
      //     setsOpened.add(Set.fromMap(setId, {"name": entry.value["setName"]}));
      //   } else {
      //     setsOpened.add(Set.fromMap(setId, {"name": entry.value["setName"]}));
      //     break;
      //   }
      // }

      // AFTER
      for (final entry in mockSetsMap.entries) {
        final setId = entry.key.toString();
        setsOpened.add(Set.fromMap(setId, {"name": entry.value["setName"]}));
      }
      return setsOpened;
    } else {
      final topicsMap = categoryMap['topics'] as Map?;
      final topicMap = topicsMap?[topicId];
      if (topicMap == null) return [];

      final setsMap = topicMap['sets'] as Map?;
      if (setsMap == null) return [];

      List<Set> setsOpened = [];
      // BEFORE - Return only opened sets
      // for (final entry in setsMap.entries) {
      //   final setId = entry.key.toString();
      //   if (passedQuizzes.contains(setId)) {
      //     setsOpened.add(Set.fromMap(setId, {"name": entry.value["setName"]}));
      //   } else {
      //     setsOpened.add(Set.fromMap(setId, {"name": entry.value["setName"]}));
      //     break;
      //   }
      // }

      // AFTER - Return all sets
      for (final entry in setsMap.entries) {
        final setId = entry.key.toString();
        setsOpened.add(Set.fromMap(setId, {"name": entry.value["setName"]}));
      }
      return setsOpened;
    }
  }

  Future<List<Question>> getQuestions(
      String categoryId, String topicId, String setId) async {
    final box = await Hive.openBox<Map>(_boxName);
    final categoryMap = box.get(categoryId.toLowerCase());
    if (categoryMap == null) return [];

    if (topicId.isEmpty) {
      // Mock Set
      final mockSetsMap = categoryMap['mock_sets'] as Map?;
      final setMap = mockSetsMap?[setId];
      return setMap?['questions']?.cast<Question>() ?? [];
    } else {
      final topicsMap = categoryMap['topics'] as Map?;
      final topicMap = topicsMap?[topicId];
      final setsMap = topicMap?['sets'] as Map?;
      final setMap = setsMap?[setId];
      return setMap?['questions']?.cast<Question>() ?? [];
    }
  }

  Future<List<Question>> getBookmarkedQuestions1(
    String categoryId,
    List<String> bookmarks,
  ) async {
    print("$bookmarks");
    final List<Question> bookmarkedQuestions = [];

    final box = await Hive.openBox<Map>(_boxName); // use your _boxName

    // Check if the category exists in local storage
    final categoryData = box.get(categoryId);
    print("1");
    if (categoryData == null) return bookmarkedQuestions;
    print("2");

    final topics = categoryData['topics'] as Map?;

    if (topics == null) return bookmarkedQuestions;
    print("3");

    // Loop through all topics
    for (final topicEntry in topics.entries) {
      final topicMap = topicEntry.value as Map?;
      final sets = topicMap?['sets'] as Map?;

      if (sets == null) continue;

      // Loop through all sets in topic
      for (final setEntry in sets.entries) {
        final setMap = setEntry.value as Map?;
        final questions = setMap?['questions'] as List?;

        if (questions == null) continue;

        // Loop through all questions in this set
        for (final q in questions) {
          final question = q as Question;
          print(question.id);
          if (bookmarks.contains(question.id)) {
            bookmarkedQuestions.add(question);
          }
        }
      }
    }

    // === MOCK QUIZZES ===
    final mockSets = categoryData['mock_sets'] as Map?;
    if (mockSets != null) {
      for (final mockEntry in mockSets.entries) {
        final mockSetMap = mockEntry.value as Map?;
        final questions = mockSetMap?['questions'] as List?;

        if (questions == null) continue;

        for (final q in questions) {
          final question = q as Question;
          if (bookmarks.contains(question.id)) {
            bookmarkedQuestions.add(question);
          }
        }
      }
    }

    return bookmarkedQuestions;
  }

  Future<List<Question>> getBookmarkedQuestions(
    String categoryId,
    List<String> bookmarks,
  ) async {
    final List<Question> bookmarkedQuestions = [];

    final box = await Hive.openBox<Map>(_boxName); // use your _boxName

    // Check if the category exists in local storage
    final categoryData = box.get(categoryId.toLowerCase());
    if (categoryData == null) return bookmarkedQuestions;

    // === PRACTICE QUIZZES ===
    final topics = categoryData['topics'] as Map?;
    if (topics != null) {
      for (final topicEntry in topics.entries) {
        final topicMap = topicEntry.value as Map?;
        final sets = topicMap?['sets'] as Map?;

        if (sets == null) continue;

        for (final setEntry in sets.entries) {
          final setMap = setEntry.value as Map?;
          final questions = setMap?['questions'] as List?;

          if (questions == null) continue;

          for (final q in questions) {
            final question = q as Question;
            if (bookmarks.contains(question.id)) {
              bookmarkedQuestions.add(question);
            }
          }
        }
      }
    }

    // === MOCK QUIZZES ===
    final mockSets = categoryData['mock_sets'] as Map?;
    if (mockSets != null) {
      for (final mockEntry in mockSets.entries) {
        final mockSetMap = mockEntry.value as Map?;
        final questions = mockSetMap?['questions'] as List?;

        if (questions == null) continue;

        for (final q in questions) {
          final question = q as Question;
          if (bookmarks.contains(question.id)) {
            bookmarkedQuestions.add(question);
          }
        }
      }
    }

    return bookmarkedQuestions;
  }

  // Function specifically for debugging
  Future<void> printLocalDataSummary() async {
    final box = await Hive.openBox<Map>(_boxName);

    print('\n🧪 Dumping Hive categoriesBox contents...\n');

    for (final entry in box.toMap().entries) {
      final categoryId = entry.key;
      final categoryMap = entry.value;

      print('📁 Category: $categoryId');

      final topics = categoryMap['topics'] as Map?;
      if (topics != null) {
        for (final topicEntry in topics.entries) {
          final topicId = topicEntry.key;
          final topicData = topicEntry.value['topic'] as Topic?;
          print('  📂 Topic: $topicId | ${topicData?.name ?? 'No name'}');

          final sets = topicEntry.value['sets'] as Map?;
          if (sets != null) {
            for (final setEntry in sets.entries) {
              final setId = setEntry.key;
              print('    📦 Set: $setId');

              final questionsRaw = setEntry.value['questions'] as List?;
              final questions = questionsRaw?.whereType<Question>().toList();
              print("      ${questions?.length ?? 0} questions");
            }
          }
        }
      }

      final mockSets = categoryMap['mock_sets'] as Map?;
      if (mockSets != null) {
        print('  🎯 Mock Sets:');
        for (final mockSetEntry in mockSets.entries) {
          final setId = mockSetEntry.key;
          print('    📦 Mock Set: $setId');

          final questionsRaw = mockSetEntry.value['questions'] as List?;
          final questions = questionsRaw?.whereType<Question>().toList();
          print("      ${questions?.length ?? 0} questions");
        }
      }
      print(''); // Add spacing between categories
    }
    print('✅ Done printing Hive data.\n');
  }
}
