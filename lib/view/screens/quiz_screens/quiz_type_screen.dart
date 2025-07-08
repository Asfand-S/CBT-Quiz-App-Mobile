import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../data/services/navigation_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../utils/themes.dart';
import '../../../view_model/user_viewmodel.dart';
import '../../../utils/dialog.dart';
import '../utility_screens/payment_screen.dart';
import 'home_screen.dart';

class QuizTypeScreen extends StatefulWidget {
  final String categoryId;

  const QuizTypeScreen({super.key, required this.categoryId});

  @override
  State<QuizTypeScreen> createState() => _QuizTypeScreenState();
}

class _QuizTypeScreenState extends State<QuizTypeScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  late Stream<List<PurchaseDetails>> _subscription;
  ProductDetails? _product;
  final String _productId = 'com.cbt.quizapp.questions';

  void googleSignInButton() async {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      if (user != null) {
        Navigator.pop(context);
        if (await FirebaseService.userExist()) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PremiumScreen()),
          );
        } else {
          FirebaseService.createUser().then(
            (onValue) => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            ),
          );
          NavigationService.navigateTo(
            '/premium',
          );
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  // premium functionalities
  Future<void> _initialize() async {
    bool available = await _iap.isAvailable();
    if (available) {
      ProductDetailsResponse response =
          await _iap.queryProductDetails({_productId});
      if (response.productDetails.isNotEmpty) {
        setState(() {
          _product = response.productDetails.first;
        });
      }
      _subscription = _iap.purchaseStream;
      _subscription.listen(_handlePurchase);
    }
    setState(() {});
  }

  Future<void> _handlePurchase(List<PurchaseDetails> purchases) async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        await userVM.updateUserData("isPremium", true);
        _iap.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Purchase failed: ${purchase.error?.message ?? ''}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryId} Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_rounded,
              size: 80,
              color: myTealShade,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose Your Mode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: myTealShade,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.menu_book, color: Colors.white),
              label: const Text(
                'Practice Quiz',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              onPressed: () {
                NavigationService.navigateTo(
                  '/topics',
                  arguments: widget.categoryId,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: myTealShade,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.teal.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.shuffle, color: Colors.white),
              label: const Text(
                'Mock Quiz',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              onPressed: () {
                NavigationService.navigateTo(
                  '/sets',
                  arguments: {
                    'categoryId': widget.categoryId,
                    'topicId': '',
                    'isMock': true
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: myTealShade,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: myTealShade,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.bookmark, color: Colors.white),
              label: const Text(
                'Bookmarks',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              onPressed: () {
                NavigationService.navigateTo(
                  '/bookmarks',
                  arguments: widget.categoryId,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: myTealShade,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.teal.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            // 👇 Only show if user is not paid
            const SizedBox(height: 24),
            Consumer<UserViewModel>(
              builder: (context, userViewModel, _) {
                if (userViewModel.currentUser.isPremium) return const SizedBox.shrink();

                return ElevatedButton.icon(
                  icon:
                      const Icon(Icons.workspace_premium, color: Colors.white),
                  label: const Text(
                    'Get Premium',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    googleSignInButton();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: myTealShade,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: Colors.teal.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
