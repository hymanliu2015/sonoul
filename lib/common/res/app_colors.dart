import 'dart:ui';

class AppColors {
  // ==================== Sonoul 主绿色系 ====================
  static const Color greenHighlight = Color(0xFFB8F5A9); // 高光
  static const Color greenLight     = Color(0xFF6DE59A); // 亮绿
  static const Color greenMain      = Color(0xFF2DDB7C); // 主绿
  static const Color greenPrimary   = Color(0xFF1ABC9C); // 核心色（品牌色）
  static const Color greenDark      = Color(0xFF0F8B6F); // 深绿
  static const Color greenDeep      = Color(0xFF072D26); // 最深背景

  // 通用
  static const Color background     = Color(0xFFF5F9F7); // 亮模式背景
  static const Color backgroundDark = Color(0xFF0A1F1B); // 暗模式背景

  // 文字
  static const Color textPrimary    = Color(0xFF212121);
  static const Color textSecondary  = Color(0xFF757575);
  static const Color textOnDark     = Color(0xFFE0F2EE);

  // 情绪色（可选）
  static const Color happy  = Color(0xFFFFC107);
  static const Color sad    = Color(0xFF64B5F6);
  static const Color angry  = Color(0xFFF44336);
  static const Color relax  = Color(0xFF9C27B0);

  static const Color tranColor = Color(0x00000000);
  
  static const Color primary = greenPrimary;
  static const Color primaryDark = greenDark;
  static const Color accent = greenPrimary;
  static const Color accentLight = greenLight;
  static const Color secondary = greenMain;

  // VIP / Premium
  static const Color goldStart = Color(0xFFFFE082); // Lighter Gold
  static const Color goldEnd   = Color(0xFFFFA000); // Darker Gold / Amber
  static const Color vipDark   = Color(0xFF1A1A1A); // Dark background for VIP card
}