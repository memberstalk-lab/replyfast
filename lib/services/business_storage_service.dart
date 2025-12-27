import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing business data persistence
/// Handles storage and retrieval of business setup information
class BusinessStorageService {
  static const String _keyIsOnboardingComplete = 'is_onboarding_complete';
  static const String _keyBusinessName = 'business_name';
  static const String _keyOwnerName = 'owner_name';
  static const String _keyWhatsappPhone = 'whatsapp_phone';
  static const String _keyBusinessAddress = 'business_address';
  static const String _keyBusinessWorkingHours = 'business_working_hours';
  static const String _keyBusinessLogoPath = 'business_logo_path';
  static const String _keyIsFakePremium = 'is_fake_premium';

  /// Check if onboarding is complete
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsOnboardingComplete) ?? false;
  }

  /// Mark onboarding as complete
  static Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsOnboardingComplete, value);
  }

  /// Save business setup data
  static Future<void> saveBusinessData({
    required String businessName,
    required String ownerName,
    required String whatsappPhone,
    required String businessAddress,
    required String businessWorkingHours,
    String? businessLogoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBusinessName, businessName);
    await prefs.setString(_keyOwnerName, ownerName);
    await prefs.setString(_keyWhatsappPhone, whatsappPhone);
    await prefs.setString(_keyBusinessAddress, businessAddress);
    await prefs.setString(_keyBusinessWorkingHours, businessWorkingHours);
    if (businessLogoPath != null) {
      await prefs.setString(_keyBusinessLogoPath, businessLogoPath);
    }
    await setOnboardingComplete(true);
  }

  /// Get business name
  static Future<String> getBusinessName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBusinessName) ?? 'Your Business';
  }

  /// Get owner name
  static Future<String> getOwnerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyOwnerName) ?? 'Business Owner';
  }

  /// Get WhatsApp phone number
  static Future<String> getWhatsappPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyWhatsappPhone) ?? '';
  }

  /// Get business address
  static Future<String> getBusinessAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBusinessAddress) ?? '';
  }

  /// Get business working hours
  static Future<String> getBusinessWorkingHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBusinessWorkingHours) ?? '';
  }

  /// Get business logo path
  static Future<String?> getBusinessLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBusinessLogoPath);
  }

  /// Get premium status - DEFAULTS TO FALSE (FREE USER)
  static Future<bool> isFakePremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFakePremium) ?? false;
  }

  /// Set premium status - ONLY called after purchase flow
  static Future<void> setFakePremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFakePremium, value);
  }

  /// Clear all business data
  static Future<void> clearBusinessData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
