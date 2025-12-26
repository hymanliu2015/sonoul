import 'package:in_app_review/in_app_review.dart';
import 'package:sonoul/utils/toast_util.dart';

class ReviewUtils {
  static final InAppReview _inAppReview = InAppReview.instance;

  /// Explicitly request review with error feedback (useful for Settings)
  static Future<void> rateAppWithFeedback() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        ToastUtils.shotToast('Rating not available on this device');
      }
    } catch (e) {
      ToastUtils.shotToast('Failed to open rating');
    }
  }
}
