import 'dart:async';
import 'package:cbt_quiz_android/data/services/firebase_service.dart';
import 'package:cbt_quiz_android/view/screens/utility_screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../data/services/navigation_service.dart';
import '../../../utils/dialog.dart';
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
  late ProductDetails product;
  final String _productId = 'com.cbt.quizapp.questions';
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  void initPurchaseListener() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          final userVM = Provider.of<UserViewModel>(context, listen: false);
          userVM.updateUserData("isPremium", true);
          Dialogs.snackBar(context, 'Premium Purchased Successfully');
        } else if (purchase.status == PurchaseStatus.error) {
          Dialogs.snackBar(context, 'Purchase Error');
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
        Dialogs.snackBar(context, 'Google user not selected');
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

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PremiumScreen()));

      if (user == null) {
        Dialogs.snackBar(context, 'Login Failed');
        return;
      }

      // Save user info to Firestore
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      final idExists = await FirebaseService()
          .checkIfEmailHasAnotherDeviceID(user.email!, userVM.currentUser.id);
      if (idExists) {
        Dialogs.snackBar(context, 'Email already linked to another device');

        return;
      }

      await userVM.updateUserData("email", user.email);
      // await userVM.updateUserData("isPremium", true);
      await purchasePremium();
    } catch (e) {
      Dialogs.snackBar(context, 'Login Failed.');
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

    setState(
      () => product = response.productDetails.first,
    );
    product = response.productDetails.first;

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
                if (userViewModel.currentUser.isPremium) {
                  return const SizedBox.shrink();
                }

                return ElevatedButton.icon(
                  icon:
                      const Icon(Icons.workspace_premium, color: Colors.white),
                  label: const Text(
                    'Get Premium',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Premium Subscription'),
                        content: const Text(
                            '''If this account is being used on multiple devices. Be careful : progress and bookmarks may not sync, and premium access could be affected.”
.”

And then 
✅He looses his progress 
✅Looses bookmark '''),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('proceed'),
                            onPressed: () async {
                              loginWithGoogleAndSaveToFirestore();
                              // Add subscribe logic here
                            },
                          ),
                        ],
                      ),
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
                );
              },
            ),
            const SizedBox(height: 24),
            // Consumer<UserViewModel>(
            //   builder: (context, userViewModel, _) {
            //     if (userViewModel.currentUser.isPremium) {
            //       return const SizedBox.shrink();
            //     }

            //     return ElevatedButton.icon(
            //       icon:
            //           const Icon(Icons.workspace_premium, color: Colors.white),
            //       label: const Text(
            //         'Delete account',
            //         style: TextStyle(fontSize: 18, color: Colors.white),
            //       ),
            //       onPressed: () async {
            //         try {
            //           final user = FirebaseService.auth.currentUser!;

            //           // Step 1: Trigger Google sign-in again to get fresh token
            //           final GoogleSignInAccount? googleUser =
            //               await GoogleSignIn().signIn();

            //           if (googleUser == null) {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(content: Text('Sign-in aborted')),
            //             );
            //             return;
            //           }

            //           final GoogleSignInAuthentication googleAuth =
            //               await googleUser.authentication;

            //           final credential = GoogleAuthProvider.credential(
            //             accessToken: googleAuth.accessToken,
            //             idToken: googleAuth.idToken,
            //           );

            //           // Step 2: Re-authenticate
            //           await user.reauthenticateWithCredential(credential);

            //           // Step 3: Delete user
            //           await user.delete();

            //           // Optional: Clean up user data in Firestore
            //           await FirebaseService().updateUserData(
            //               user.uid, 'deleted', true); // or delete doc

            //           // Optional: Navigate away
            //           Navigator.pushReplacementNamed(context, '/home');
            //         } on FirebaseAuthException catch (e) {
            //           if (e.code == 'requires-recent-login') {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(
            //                   content: Text(
            //                       'Please re-login to delete your account.')),
            //             );
            //           } else {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               SnackBar(content: Text('Error: ${e.message}')),
            //             );
            //           }
            //         } catch (e) {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             SnackBar(content: Text('Unexpected error: $e')),
            //           );
            //         }
            //       },
            //       style: ElevatedButton.styleFrom(
            //         minimumSize: const Size(double.infinity, 60),
            //         backgroundColor: myTealShade,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(16),
            //         ),
            //         elevation: 8,
            //         shadowColor: Colors.teal.shade800,
            //         padding: const EdgeInsets.symmetric(vertical: 16),
            //       ),
            //     );
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
