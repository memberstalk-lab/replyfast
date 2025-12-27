import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sizer/sizer.dart';

class UpgradeToProScreen extends StatefulWidget {
  const UpgradeToProScreen({super.key});

  @override
  State<UpgradeToProScreen> createState() => _UpgradeToProScreenState();
}

class _UpgradeToProScreenState extends State<UpgradeToProScreen> {
  bool _isLoading = false;
  String _selectedPlan = 'yearly';
  Offering? _offering;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      setState(() {
        _offering = offerings.current;
      });
    } catch (e) {
      debugPrint("Offering error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(theme)
            : _offering == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(theme),
                        _buildTitle(theme),
                        SizedBox(height: 3.h),
                        _buildPricingOptions(theme),
                        SizedBox(height: 3.h),
                        _buildActionButtons(theme),
                        SizedBox(height: 2.h),
                        _buildTerms(theme),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: theme.textTheme.bodyLarge?.color),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade to Pro',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Choose Your Plan',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions(ThemeData theme) {
    final monthly = _offering?.monthly;
    final annual = _offering?.annual;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          if (monthly != null)
            RadioListTile(
              title: Text("Monthly - ${monthly.storeProduct.priceString}"),
              value: 'monthly',
              groupValue: _selectedPlan,
              onChanged: (value) => setState(() => _selectedPlan = value!),
            ),
          if (annual != null)
            RadioListTile(
              title: Text("Yearly - ${annual.storeProduct.priceString}"),
              subtitle: const Text("Save 33%"),
              value: 'yearly',
              groupValue: _selectedPlan,
              onChanged: (value) => setState(() => _selectedPlan = value!),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startTrial,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Start 7-Day Free Trial',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
        ],
      ),
    );
  }

  Widget _buildTerms(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        'By subscribing, you agree to our Terms of Service and Privacy Policy.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14.w,
            height: 14.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Processing secure payment...',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _startTrial() async {
    if (_offering == null) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final package = _selectedPlan == 'yearly'
          ? _offering!.annual
          : _offering!.monthly;

      final purchaseResult = await Purchases.purchasePackage(package!);
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.all["pro_access"]?.isActive ?? false;

      if (isPro) {
        Navigator.pushReplacementNamed(context, '/home-screen');
      }
    } catch (e) {
      debugPrint("Purchase error: $e");
    }

    setState(() => _isLoading = false);
  }
}
