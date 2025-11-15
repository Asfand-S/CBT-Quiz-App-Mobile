import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../../../view_model/user_viewmodel.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  final String _productId = 'com.cbt.quizapp.allunlocked';

  ProductDetails? _product;
  late final Stream<List<PurchaseDetails>> _purchaseSubscription;

  @override
  void initState() {
    super.initState();
    _initializeInAppPurchase();
  }

  Future<void> _initializeInAppPurchase() async {
    // Check Play Store availability
    final available = await _iap.isAvailable();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Play Store not available")),
      );
      return;
    }

    // Query product details
    final response = await _iap.queryProductDetails({_productId});
    if (response.productDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product not found")),
      );
      return;
    }

    setState(() {
      _product = response.productDetails.first;
    });

    // Listen for purchase updates
    _purchaseSubscription = _iap.purchaseStream;
    _purchaseSubscription.listen(_handlePurchaseUpdates, onError: (e) {
      debugPrint("Purchase stream error: $e");
    });
  }

  /// Handle all purchase updates including restore
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    final userVM = Provider.of<UserViewModel>(context, listen: false);

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _verifyAndUnlockPremium(purchase, userVM);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Purchase failed: ${purchase.error?.message}")),
        );
      }

      // Must be called after handling purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Validate and unlock premium features
  Future<void> _verifyAndUnlockPremium(
      PurchaseDetails purchase, UserViewModel userVM) async {
    // Normally you’d verify this with your server, but here we mark premium directly
    await userVM.updateUserData('isPremium', true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Premium unlocked!")),
    );
  }

  /// Initiate a purchase
  Future<void> _buyProduct() async {
    if (_product == null) return;

    final purchaseParam = PurchaseParam(productDetails: _product!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Trigger Play Store restore process
  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Restoring your purchases...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Premium Upgrade")),
      body: Center(
        child: _product == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Unlock all premium features!",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _buyProduct,
                    child: Text("Buy Premium • ${_product!.price}"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _restorePurchases,
                    child: const Text("Restore Purchases"),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
