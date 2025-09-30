import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
              _buildSectionTitle('Your Privacy Matters'),
              const SizedBox(height: 8),
              _buildCard(
                child: const Text(
                  'Your privacy is a top priority at Nursing CBT NG. We designed our app to be a secure and private learning space. Here’s a simple summary of our approach:',
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('What We Do and Don’t Collect'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                        '• We Collect the Absolute Minimum: No name, no age, no separate account or password required.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Secure Payments by Google: All payments are handled by Google Play Store. We never see or store your financial info.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Your Progress is Private: Scores, bookmarks, and test history stay on your device only.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• Purchase Verification Only: We only get a Google confirmation (with your email) to restore premium access on new devices.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                    SizedBox(height: 10),
                    Text(
                        '• We Never Sell Your Data: No selling, renting, or sharing of your info with marketers — ever.',
                        style: TextStyle(fontSize: 16, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('Full Policy'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This is just a summary. For complete details about how we handle your data and your rights, please read our full policy.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(
                            'https://docs.google.com/document/d/1MKS0t4KxpIk_1BiTj-VeB9gWVJw3bq9cpvWmwXk8KOI/edit?usp=sharing');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text(
                        '[Read our Full Privacy Policy Here]',
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
          child: const Icon(Icons.privacy_tip, size: 36, color: Colors.green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Privacy Policy',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Your privacy, protected.',
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        )
      ],
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
