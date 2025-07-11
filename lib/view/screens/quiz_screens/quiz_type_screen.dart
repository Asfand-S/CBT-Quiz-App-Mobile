import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../data/services/navigation_service.dart';
import '../../../utils/themes.dart';
import '../../../view_model/user_viewmodel.dart';

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
    initPurchaseListener();
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  ProductDetails? _product;
  final String _productId = 'com.cbt.quizapp.questions';
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  void initPurchaseListener() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          final userVM = Provider.of<UserViewModel>(context, listen: false);
          userVM.updateUserData("isPremium", true);
          print('🎉 Premium Purchased Successfully');
        } else if (purchase.status == PurchaseStatus.error) {
          print('❌ Purchase Error: ${purchase.error}');
        }
      }
    });
  }

  Future<void> loginWithGoogleAndSaveToFirestore() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Sign-in aborted by user
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Save user info to Firestore
        final userVM = Provider.of<UserViewModel>(context, listen: false);
        await userVM.updateUserData("email", user.email);
        await userVM.updateUserData("isPremium", true);
        await purchasePremium();
      } else {
        return;
      }
    } catch (e) {
      print('Login failed: $e');
      return;
    }
  }

  Future<void> purchasePremium() async {
    final bool available = await _iap.isAvailable();

    if (!available) {
      print('IAP not available');
      return;
    }

    // Get product details
    ProductDetailsResponse response =
        await _iap.queryProductDetails({_productId});
    if (response.productDetails.isEmpty) {
      print('Product not found');
      return;
    }

    final ProductDetails product = response.productDetails.first;

    // Buy the product
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
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
                if (userViewModel.currentUser.isPremium)
                  return const SizedBox.shrink();

                return ElevatedButton.icon(
                  icon:
                      const Icon(Icons.workspace_premium, color: Colors.white),
                  label: const Text(
                    'Get Premium',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () async {
                    loginWithGoogleAndSaveToFirestore();
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
