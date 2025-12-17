import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/utils/toast_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MemberController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  RxBool isAvailable = false.obs;
  RxBool isLoading = false.obs;
  RxBool isPurchasing = false.obs;
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
    isPurchasing.value = true;
    if (products.isNotEmpty) {
      final product = products.firstWhereOrNull((p) => p.id == selectedProductId.value);
      if (product != null) {
        buyProduct(product);
      } else {
        isPurchasing.value = false;
        ToastUtils.shotToast('Products not available', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
      }
    } else {
      isPurchasing.value = false;
      ToastUtils.shotToast('Products not available', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
    }
  }

  void buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void restorePurchases() {
    _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isPurchasing.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
          ToastUtils.shotToast('Purchase failed', Toast.LENGTH_SHORT, ToastGravity.BOTTOM, Colors.red, Colors.white);
          isPurchasing.value = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          
          // Verify with Supabase
          isPurchasing.value = true;
          await _verifyPurchase(
            productId: purchaseDetails.productID,
            purchaseToken: purchaseDetails.verificationData.serverVerificationData,
            platform: GetPlatform.isIOS ? 'ios' : 'android',
          );
          
          isPurchasing.value = false;
          debugPrint("Purchase successful!'");

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
        method: HttpMethod.post,
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
        final dash = Get.find<DashController>();
        dash.isPremium.value = true; // Immediate local update
        await dash.checkSubscription(); // Server-confirmed refresh
      }
      
    } catch (e) {
      debugPrint("Verification error: $e");
      // Don't block the user, but maybe retry later or show error
    } finally {
      if (isPurchasing.value) {
        isPurchasing.value = false;
      }
    }
  }
}
