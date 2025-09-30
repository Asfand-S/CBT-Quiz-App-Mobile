import 'package:flutter/material.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use This App'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildIntro(),
              const SizedBox(height: 18),
              _buildSectionTitle(
                  'Step 1: Build Your Foundation with Practice Mode'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                        '• Choose Your Field: Select either the Nursing or Midwifery section from the main menu.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Select a Subject: Subjects are laid out according to the NMCN syllabus. Pick a topic to master.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Learn as You Go: Immediate feedback with correct answers and explanations after each question.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Unlock Your Path: Score at least 60% in a stage to unlock the next one.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text('Use Practice Mode to turn weak areas into strengths!',
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('Step 2: Test Your Readiness with Mock Mode'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                        '• Prepare for the Real Thing: Select Mock Mode to start a full-length examination.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Realistic Conditions: 2 hours to answer 250 questions with a visible timer.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• No Instant Answers: Correct answers appear only after submission.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Review Your Performance: See your score and review incorrect answers.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        'Use Mock Mode to perfect time management and boost confidence!',
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('Key Features to Help You Succeed'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                        '• Bookmarks: Save questions to review later from one place.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Free vs. Premium: Free version offers a sample. Upgrade to Premium for unlimited subjects, explanations, and mock exams.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your journey to becoming a licensed professional starts now. Good luck with your studies!',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text('© ${DateTime.now().year} Nursing CBT NG',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school, size: 36, color: Colors.green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('How to Use This App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Your Path to Success',
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildIntro() {
    return const Text(
      'Welcome! We\'ve designed this app to help you prepare in two powerful ways: building your knowledge and testing your readiness. Follow these steps to maximize your study sessions.',
      style: TextStyle(fontSize: 16, height: 1.4),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600));
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: child,
      ),
    );
  }
}
