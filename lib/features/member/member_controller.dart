import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sonoul/common/res/app_colors.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/utils/loading_util.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  RxBool isAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxString selectedProductId = 'sonoul_annual'.obs; // Default to yearly

  RxList<ProductDetails> products = <ProductDetails>[].obs;


  // Example product IDs
  // Product IDs
  final Set<String> _kIds = <String>{
    'sonoul_week',
    'sonoul_monthly', 
    'sonoul_annual'
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

    isLoading.value = false;
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
    LoadingUtils().showLoading();
    Future.delayed(const Duration(seconds: 2), () async {
      // Simulate successful verification
      await _verifyPurchase(
        productId: productId,
        purchaseToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        platform: 'android',
      );
      
      isLoading.value = false;
      LoadingUtils().hideLoading();
      ToastUtils.shotToast('Subscribed to $productId (Mock)', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, AppColors.greenMain, Colors.white);
      Get.back(); // Go back to previous screen
    });
  }

  void restorePurchases() {
    _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isLoading.value = true;
        LoadingUtils().showLoading();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
          ToastUtils.shotToast('Purchase failed', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
          isLoading.value = false;
          LoadingUtils().hideLoading();
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          
          // Verify with Supabase
          isLoading.value = true;
          await _verifyPurchase(
            productId: purchaseDetails.productID,
            purchaseToken: purchaseDetails.verificationData.serverVerificationData,
            platform: GetPlatform.isIOS ? 'ios' : 'android',
          );
          
          isLoading.value = false;
          LoadingUtils().hideLoading();
          ToastUtils.shotToast('Purchase successful!', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, AppColors.greenMain, Colors.white);
          
          if (Get.isRegistered<DashController>()) {
            await Get.find<DashController>().checkSubscription();
          }
          Get.back();
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyPurchase({
    required String productId,
    required String purchaseToken,
    required String platform,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final res = await supabase.functions.invoke(
        'handle-subscription',
        body: {
          'user_id': user.id,
          'product_id': productId,
          'purchase_token': purchaseToken,
          'platform': platform,
        },
      );
      
      if (res.status != 200) {
        throw Exception('Failed to verify subscription: ${res.data}');
      }
      
      // Refresh user status in DashController
      if (Get.isRegistered<DashController>()) {
        await Get.find<DashController>().checkSubscription();
      }
      
    } catch (e) {
      debugPrint("Verification error: $e");
      // Don't block the user, but maybe retry later or show error
    }
  }
}
