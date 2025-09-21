import 'package:cbt_quiz_android/data/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../data/services/navigation_service.dart';
import '../../../view_model/user_viewmodel.dart';
import '../../../utils/themes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../view_model/theme_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> categories = [
    {"title": "Nursing", "image": "assets/images/stethoscope.png"},
    {"title": "Midwifery", "image": "assets/images/pregnancy.png"},
  ];

  int _selectedIndex = 0; // Track the selected bottom navigation item

  @override
  Widget build(BuildContext context) {
    Future<void> _openRedeemPage() async {
      final Uri url = Uri.parse("https://play.google.com/redeem");
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception("Could not launch $url");
      }
    }

    Future<void> openWhatsAppWithConfirmation(BuildContext context) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Open WhatsApp?'),
          content: const Text(
              '''Before you leave the app, here’s what you should know:

This group is a supportive community where you can:

Discuss study topics with peers

Get help and share tips

Participate in fun challenges and win prizes

If you're ready to join, tap the link below and become part of our growing community!'''),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final channelUrl =
            Uri.parse('https://whatsapp.com/channel/0029VbAvkqrDuMRlrq24EU2d');
        final webUrl =
            Uri.parse('https://chat.whatsapp.com/invite/your_invite_code');

        if (await canLaunchUrl(channelUrl)) {
          await launchUrl(channelUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp Channel')),
          );
        }
      }
    }

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return FutureBuilder<bool>(
      future: userViewModel.canAccessApp(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.data!) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 60,
                    color: myTealShade,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please connect to the internet.',
                    style: TextStyle(
                      fontSize: 20,
                      color: myTealShade,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ Access allowed
        return SafeArea(
          child: Scaffold(
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.tealAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explore Options',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Colors.teal),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      NavigationService.navigateTo('/privacyPolicy');
                      Navigator.pop(context); // Close the drawer
                    },
                    tileColor: Colors.teal.withOpacity(0.05),
                    hoverColor: Colors.teal.withOpacity(0.1),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.teal),
                    title: const Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      NavigationService.navigateTo('/termsAndConditions');
                      Navigator.pop(context); // Close the drawer
                    },
                    tileColor: Colors.teal.withOpacity(0.05),
                    hoverColor: Colors.teal.withOpacity(0.1),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.delete_forever, color: Colors.teal),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      try {
                        final user = FirebaseService.auth.currentUser!;

                        // Step 1: Trigger Google sign-in again to get fresh token
                        final GoogleSignInAccount? googleUser =
                            await GoogleSignIn().signIn();

                        if (googleUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sign-in aborted')),
                          );
                          return;
                        }

                        final GoogleSignInAuthentication googleAuth =
                            await googleUser.authentication;

                        final credential = GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );

                        // Step 2: Re-authenticate
                        await user.reauthenticateWithCredential(credential);

                        // Step 3: Delete user
                        await user.delete();

                        // Optional: Clean up user data in Firestore
                        await FirebaseService().updateUserData(
                            user.uid, 'deleted', true); // or delete doc

                        // Optional: Navigate away
                        Navigator.pushReplacementNamed(context, '/home');
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'requires-recent-login') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please re-login to delete your account.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.message}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Unexpected error: $e')),
                        );
                      }
                    },
                    tileColor: Colors.teal.withOpacity(0.05),
                    hoverColor: Colors.teal.withOpacity(0.1),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.teal),
                    title: const Text(
                      'Redeem promo code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: _openRedeemPage,

                    // lose the drawer

                    tileColor: Colors.teal.withOpacity(0.05),
                    hoverColor: Colors.teal.withOpacity(0.1),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.teal),
                    title: const Text(
                      'Redeem wallet code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      NavigationService.navigateTo('/howToUse');
                    },
                    tileColor: Colors.teal.withOpacity(0.05),
                    hoverColor: Colors.teal.withOpacity(0.1),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.teal),
                    title: const Text(
                      'Night theme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                    tileColor: Colors.teal.withOpacity(0.05),
                    hoverColor: Colors.teal.withOpacity(0.1),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              title: const Text('Quiz Categories'),
              backgroundColor: myTealShade, // Align with teal theme
            ),
            body: Column(
              children: [
                const SizedBox(height: 80),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 1,
                    childAspectRatio: 2.4,
                    mainAxisSpacing: 12,
                    children: categories.map((category) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(40), // Updated to 50
                        ),
                        elevation: 10,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(40), // Updated to 50
                          child: InkWell(
                            onTap: () => NavigationService.navigateTo(
                              '/quizType',
                              arguments: category["title"],
                            ),
                            child: Container(
                              decoration: gradientBackground,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.asset(
                                        category["image"]!,
                                        height: 60,
                                        width: 60,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category["title"]!,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 2.5,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 6.0,
                                            color: Colors.black45,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType
                  .fixed, // Ensure all items are displayed
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                switch (index) {
                  case 0:
                    // NavigationService.navigateTo('/aboutus');
                    break;
                  case 1:
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Rate Us feature coming soon!')),
                    );
                    break;
                  case 2:
                    openWhatsAppWithConfirmation(context);
                    break;
                  case 3:
                    // Placeholder for Messages action
                    NavigationService.navigateTo('/announce');
                    break;
                }
              },
              backgroundColor: myTealShade,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10, // Slightly increased for readability
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 8,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.share, size: 24), // Reduced icon size
                  label: 'Share',
                  tooltip: 'Share',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info_outline, size: 24), // Reduced icon size
                  label: 'Rate us',
                  tooltip: 'Rate us',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_rate, size: 24), // Reduced icon size
                  label: 'Join Whatsapp',
                  tooltip: 'Join Whatsapp',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message, size: 24), // Reduced icon size
                  label: 'Messages',
                  tooltip: 'Messages',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
