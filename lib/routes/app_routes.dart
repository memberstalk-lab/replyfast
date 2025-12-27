import 'package:flutter/material.dart';
import '../presentation/upgrade_to_pro_screen/upgrade_to_pro_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/my_replies_screen/my_replies_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/qr_generator_screen/qr_generator_screen.dart';
import '../presentation/business_setup_onboarding_screen/business_setup_onboarding_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String upgradeToPro = '/upgrade-to-pro-screen';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String myReplies = '/my-replies-screen';
  static const String home = '/home-screen';
  static const String qrGenerator = '/qr-generator-screen';
  static const String businessSetupOnboarding =
      '/business-setup-onboarding-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    upgradeToPro: (context) => const UpgradeToProScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    myReplies: (context) => const MyRepliesScreen(),
    home: (context) => const HomeScreen(),
    qrGenerator: (context) => const QrGeneratorScreen(),
    businessSetupOnboarding: (context) => const BusinessSetupOnboardingScreen(),
  };
}
