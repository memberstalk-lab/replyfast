import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Pro Header Widget
/// Orange gradient card highlighting Pro branding with premium badge styling
class ProHeaderWidget extends StatelessWidget {
  const ProHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9500), Color(0xFFFFB340)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9500).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pro Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'bolt',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'PRO',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Main Heading
          Text(
            'Unlock Unlimited Potential',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),

          // Subheading
          Text(
            'Respond faster, grow your business, and delight your customers with Pro features',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),

          // Key Benefits Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBenefitItem(theme, 'Unlimited', 'Replies', 'all_inclusive'),
              Container(
                width: 1,
                height: 6.h,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildBenefitItem(theme, 'Advanced', 'QR Codes', 'qr_code_2'),
              Container(
                width: 1,
                height: 6.h,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildBenefitItem(theme, 'Priority', 'Support', 'support_agent'),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual benefit item
  Widget _buildBenefitItem(
    ThemeData theme,
    String title,
    String subtitle,
    String iconName,
  ) {
    return Column(
      children: [
        CustomIconWidget(iconName: iconName, color: Colors.white, size: 28),
        SizedBox(height: 0.5.h),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
