import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/navigation_service.dart';
import '../../view_model/user_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  final List<String> categories = ['nursing', 'midwifery'];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    return FutureBuilder<bool>(
      future: userViewModel.canAccessApp(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.teal.shade700,
                strokeWidth: 6,
                backgroundColor: Colors.teal.shade100,
              ),
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
                    color: Colors.teal.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please connect to the internet.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.teal.shade700,
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
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Quiz Categories',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 1.0,
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.teal.shade700,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 187, 226, 223),
                  const Color.fromARGB(255, 183, 218, 214),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(20),
                    crossAxisCount: 1,
                    childAspectRatio: 1.8,
                    mainAxisSpacing: 16,
                    children: categories.map((cat) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => NavigationService.navigateTo(
                            '/quizType',
                            arguments: cat,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade300,
                                  Colors.teal.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.shade200.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                cat.toUpperCase(),
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
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.info_outline,
                        onPressed: () {},
                        tooltip: 'About',
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.share,
                        onPressed: () {},
                        tooltip: 'Share',
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.star_rate,
                        onPressed: () {},
                        tooltip: 'Rate Us',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Expanded(
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 4.0,
                    color: Colors.black26,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
