import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
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
              _buildSectionTitle('For Educational Use Only'),
              const SizedBox(height: 8),
              _buildCard(
                child: const Text(
                  'This app is a study guide to help you prepare for your exams. The content is not official medical advice and using the app does not guarantee you will pass your council exams. Your success depends on your hard work!',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('One-Time Premium Upgrade'),
              const SizedBox(height: 8),
              _buildCard(
                child: const Text(
                  'The app is free to try with limited access. You can unlock all features—including all questions, mock exams, and offline mode—with a single, one-time payment. There are no recurring subscriptions.',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('Respect Our Content'),
              const SizedBox(height: 8),
              _buildCard(
                child: const Text(
                  'All questions, explanations, and content in this app are our intellectual property. Please do not copy, share, resell, or distribute them without our permission.',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('Fair Play'),
              const SizedBox(height: 8),
              _buildCard(
                child: const Text(
                  'Please use the app as intended. Do not try to hack the app, bypass its features, or share your Premium access with others. Your purchase is a license for your personal use only.',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('"As Is" Service'),
              const SizedBox(height: 8),
              _buildCard(
                child: const Text(
                  'We work hard to provide high-quality content, but the app is provided "as is." We are not liable for any errors in the content or for your final examination results.',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('Full Terms and Conditions'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This is a summary of our main terms. For the complete legal details that govern your use of the app, please read our full Terms and Conditions.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(
                            'https://docs.google.com/document/d/1sFOgpO_g4udyp-x7jhGaduSyyAyVEjxaF07YVYXmwxw/edit?usp=sharing');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        '[Read our Full Terms and Conditions Here]',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
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
          child: const Icon(Icons.rule, size: 36, color: Colors.green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Terms of Use',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Key rules to guide your use.',
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildIntro() {
    return const Text(
      'Welcome to Nursing CBT NG! By using our app, you agree to a few key rules designed to keep our community fair and our content protected.',
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
