import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Nursing CBT NG'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nursing CBT NG is a powerful exam prep app built for nursing and midwifery students preparing for the Nursing and Midwifery Council of Nigeria (NMCN) exams.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                'It features over 15,000 CBT questions and answers, covering the full syllabus for both nursing and midwifery — organized course by course and topic by topic for easy learning.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                'The app also includes more than 20 Council mock exam sets based on past questions to help students test their readiness and improve their confidence before the actual exam.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Key Features:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
              const SizedBox(height: 12),
              featureBullet('15,000+ practice questions with answers'),
              featureBullet('Topic-by-topic and course-by-course breakdown'),
              featureBullet(
                  'Mock past questions for both nursing and midwifery'),
              featureBullet('Instant feedback and detailed explanations'),
              featureBullet('Based on the NMCN syllabus'),
              featureBullet(
                  'Also useful for students in Anglophone countries with similar curricula'),
            ],
          ),
        ),
      ),
    );
  }

  Widget featureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
