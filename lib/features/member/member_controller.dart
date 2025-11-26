import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MemberController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  RxBool isAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxString selectedProductId = 'sonoul_premium_yearly'.obs; // Default to yearly

  RxList<ProductDetails> products = <ProductDetails>[].obs;


  // Example product IDs
  final Set<String> _kIds = <String>{
    'sonoul_premium_weekly',
    'sonoul_premium_monthly', 
    'sonoul_premium_yearly'
  };
  
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void onInit() {
    super.onInit();
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStore();
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> initStore() async {
    isLoading.value = true;
    try {
      final bool available = await _iap.isAvailable();
      isAvailable.value = available;
      
      if (available) {
        final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
        if (response.notFoundIDs.isNotEmpty) {
          debugPrint("Products not found: ${response.notFoundIDs}");
        }
        products.value = response.productDetails;
      }
    } catch (e) {
      debugPrint("Store init error: $e");
    }
    
    // Always load mock data if empty (for testing/emulator)
    if (products.isEmpty) {
       _addMockProducts();
    }
    
    isLoading.value = false;
  }
  
  void _addMockProducts() {
    // Mock data for UI testing
    products.value = [
      ProductDetails(
        id: 'sonoul_premium_weekly',
        title: 'Weekly Premium',
        description: 'Weekly subscription',
        price: '\$4.99',
        rawPrice: 4.99,
        currencyCode: 'USD',
      ),
      ProductDetails(
        id: 'sonoul_premium_monthly',
        title: 'Monthly Premium',
        description: 'Monthly subscription',
        price: '\$9.99',
        rawPrice: 9.99,
        currencyCode: 'USD',
      ),
      ProductDetails(
        id: 'sonoul_premium_yearly',
        title: 'Yearly Premium',
        description: 'Yearly subscription',
        price: '\$69.99',
        rawPrice: 69.99,
        currencyCode: 'USD',
      ),
    ];
  }

  void selectProduct(String productId) {
    selectedProductId.value = productId;
  }

  void buySelectedProduct() {
    if (products.isNotEmpty) {
      final product = products.firstWhereOrNull((p) => p.id == selectedProductId.value);
      if (product != null) {
        buyProduct(product);
      } else {
        // Mock buy if product not found in real list (e.g. emulator)
        mockBuy(selectedProductId.value);
      }
    } else {
      mockBuy(selectedProductId.value);
    }
  }

  void buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
  
  // Mock buy for testing UI without real IAP
  void mockBuy(String productId) {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      ToastUtils.shotToast('Subscribed to $productId (Mock)', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, AppColors.greenMain, Colors.white);
    });
  }

  void restorePurchases() {
    _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
          ToastUtils.shotToast('Purchase failed', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Deliver product
          // Verify with Supabase here
          ToastUtils.shotToast('Purchase successful!', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, AppColors.greenMain, Colors.white);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }
}
