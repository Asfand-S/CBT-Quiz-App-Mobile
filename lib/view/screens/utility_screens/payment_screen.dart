import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../../../view_model/user_viewmodel.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late Stream<List<PurchaseDetails>> _subscription;
  ProductDetails? _product;

  final String _productId = 'com.cbt.quizapp.questions';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

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
        await userVM.updateUserData('isPremium', true);
        _iap.completePurchase(purchase);
      } 
      else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content:
                  Text("Purchase failed: ${purchase.error?.message ?? ''}")),
        );
      }
    }
  }

  Future<void> _buyProduct() async {
    if (_product != null) {
      final userVM = Provider.of<UserViewModel>(context, listen: false);
      final purchaseParam = PurchaseParam(productDetails: _product!);
      bool result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Purchase failed")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Purchase Succeed"))
        );
        userVM.updateUserData('isPremium', true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Premium Upgrade")),
      body: Center(
        child: _product != null
                ? ElevatedButton(
                    onPressed: _buyProduct,
                    child: Text("Unlock Premium • ${_product!.price}"),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
