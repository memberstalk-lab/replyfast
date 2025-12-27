import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../services/business_storage_service.dart';

/// Native Logo Splash Screen
/// Professional app launch with Reply Fast branding and initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// Setup fade animation for logo
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  /// Initialize app and check onboarding status
  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        _checkOnboardingStatus(),
        Future.delayed(const Duration(seconds: 3)), // Minimum splash duration
      ]);

      if (mounted) {
        setState(() => _isInitialized = true);
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialized = true);
        await Future.delayed(const Duration(seconds: 1));
        _navigateToNextScreen();
      }
    }
  }

  /// Check if onboarding is complete
  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Status will be checked in navigation logic
  }

  /// Initialize fake premium mode for demo/testing
  Future<void> _initializeFakePremium() async {
    await BusinessStorageService.setFakePremium(true);
  }

  /// Navigate to appropriate screen based on onboarding status
  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    final isOnboardingComplete =
        await BusinessStorageService.isOnboardingComplete();

    if (isOnboardingComplete) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.businessSetupOnboarding,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Primary green
              Color(0xFF2E7D32), // Darker green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: CustomImageWidget(
                    imageUrl: 'assets/images/logo-1766456844432.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Loading Indicator
              if (!_isInitialized)
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
