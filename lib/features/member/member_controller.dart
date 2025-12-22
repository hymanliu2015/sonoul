import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sonoul/features/dash/dash_controller.dart';
import 'package:sonoul/utils/toast_util.dart';

class MemberController extends GetxController {
  /// 是否正在加载商品/套餐
  RxBool isLoading = false.obs;

  /// 是否正在发起购买/恢复
  RxBool isPurchasing = false.obs;

  /// 当前可用套餐列表（来自 RevenueCat Offerings）
  RxList<Package> packages = <Package>[].obs;

  /// 选中的套餐 identifier（package.identifier）
  RxString selectedPackageId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOfferings();
  }

  /// 加载 RevenueCat 后台配置的 Offerings / Packages
  Future<void> _loadOfferings() async {
    isLoading.value = true;
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        debugPrint('No offerings / packages configured in RevenueCat');
        ToastUtils.shotToast('Products not available');
        packages.clear();
        selectedPackageId.value = '';
      } else {
        packages.value = current.availablePackages;
        // 默认选中第一个套餐
        selectedPackageId.value = current.availablePackages.first.identifier;
      }
    } catch (e) {
      debugPrint('Error loading offerings: $e');
      ToastUtils.shotToast('Failed to load products');
      packages.clear();
      selectedPackageId.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  void selectPackage(String packageId) {
    selectedPackageId.value = packageId;
  }

  /// 购买当前选中的套餐
  Future<void> buySelectedProduct() async {
    if (packages.isEmpty || selectedPackageId.value.isEmpty) {
      ToastUtils.shotToast('Products not available');
      return;
    }

    final pkg = packages
        .where((p) => p.identifier == selectedPackageId.value)
        .cast<Package?>()
        .firstOrNull;
    if (pkg == null) {
      ToastUtils.shotToast('Products not available');
      return;
    }

    await _purchasePackage(pkg);
  }

  Future<void> _purchasePackage(Package pkg) async {
    try {
      isPurchasing.value = true;

      final paras = PurchaseParams.package(pkg);
      final customerInfo = await Purchases.purchase(paras);

      // 根据 entitlements 判断是否已解锁会员
      final entitlements = customerInfo.customerInfo.entitlements.active;
      if (entitlements.isNotEmpty) {
        ToastUtils.shotToast('Purchase successful');

        // 刷新本地 premium 状态（依然通过 Supabase 的 subscriptions 表）
        if (Get.isRegistered<DashController>()) {
          await Get.find<DashController>().checkSubscription();
        }
        Get.back();
      } else {
        ToastUtils.shotToast('No active subscription found');
      }
    } on PurchasesError {
      // 用户取消，无需提示错误
    } catch (e) {
      debugPrint('Purchase error: $e');
      ToastUtils.shotToast('Purchase failed');
    } finally {
      isPurchasing.value = false;
    }
  }

  /// 恢复历史购买
  Future<void> restorePurchases() async {
    try {
      isPurchasing.value = true;
      final customerInfo = await Purchases.restorePurchases();
      final entitlements = customerInfo.entitlements.active;
      if (entitlements.isNotEmpty) {
        ToastUtils.shotToast('Restore successful');
        if (Get.isRegistered<DashController>()) {
          await Get.find<DashController>().checkSubscription();
        }
        Get.back();
      } else {
        ToastUtils.shotToast('No purchases to restore');
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      ToastUtils.shotToast('Restore failed');
    } finally {
      isPurchasing.value = false;
    }
  }
}
