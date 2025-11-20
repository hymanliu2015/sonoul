import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sonoul/common/res/app_colors.dart';

class MemberController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  RxBool isAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxList<ProductDetails> products = <ProductDetails>[].obs;
  RxList<PurchaseDetails> purchases = <PurchaseDetails>[].obs;
  
  // Example product IDs
  final Set<String> _kIds = <String>{'sonoul_premium_monthly', 'sonoul_premium_yearly'};
  
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
    final bool available = await _iap.isAvailable();
    isAvailable.value = available;
    
    if (available) {
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        // Handle missing IDs
        debugPrint("Products not found: ${response.notFoundIDs}");
      }
      products.value = response.productDetails;
      
      // For demo purposes, if no products found (emulator), add mock products
      if (products.isEmpty) {
         _addMockProducts();
      }
    } else {
      // Mock for emulator if store not available
      _addMockProducts();
    }
    isLoading.value = false;
  }
  
  void _addMockProducts() {
    // Mock data for UI testing
    // Note: ProductDetails is not easily instantiable with public constructor in some versions, 
    // but let's try to rely on the UI handling empty list or just showing static cards if empty.
    // Actually, we can just use a separate list for UI if products are empty.
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
      Get.snackbar('Success', 'Subscribed to $productId (Mock)', backgroundColor: AppColors.greenMain, colorText: Colors.white);
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
          Get.snackbar('Error', 'Purchase failed', backgroundColor: Colors.red, colorText: Colors.white);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Deliver product
          // Verify with Supabase here
          Get.snackbar('Success', 'Purchase successful!', backgroundColor: AppColors.greenMain, colorText: Colors.white);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }
}
