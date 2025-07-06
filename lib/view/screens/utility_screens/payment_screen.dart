import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../data/services/firebase_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  _PremiumScreenState createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late Stream<List<PurchaseDetails>> _subscription;
  ProductDetails? _product;
  final FirebaseService _firebaseService = FirebaseService();

  final String _productId = 'com.cbt.quizapp.questions';

  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _isPremium = await _isPremiumForThisDevice();
    if (!_isPremium) {
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
    }
    setState(() {});
  }

  Future<void> _handlePurchase(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        await _savePremiumForThisDevice();
        setState(() => _isPremium = true);
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

  Future<void> _buyProduct() async {
    if (_product != null) {
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
        _firebaseService.setPremium();
      }
    }
  }

  Future<void> _savePremiumForThisDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await _getDeviceId();
    await prefs.setBool('isPremium', true);
    await prefs.setString('premiumDeviceId', deviceId);
  }

  Future<bool> _isPremiumForThisDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDeviceId = prefs.getString('premiumDeviceId');
    final currentDeviceId = await _getDeviceId();
    return prefs.getBool('isPremium') == true &&
        savedDeviceId == currentDeviceId;
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id ?? androidInfo.fingerprint ?? 'unknown_device';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Premium Upgrade")),
      body: Center(
        child: _isPremium
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.verified, size: 80, color: Colors.green),
                  SizedBox(height: 10),
                  Text("Premium Active!", style: TextStyle(fontSize: 24)),
                ],
              )
            : _product != null
                ? ElevatedButton(
                    onPressed: _buyProduct,
                    child: Text("Unlock Premium • ${_product!.price}"),
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
