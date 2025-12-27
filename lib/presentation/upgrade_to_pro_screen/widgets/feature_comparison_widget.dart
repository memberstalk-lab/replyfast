import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class FeatureComparisonWidget extends StatelessWidget {
  const FeatureComparisonWidget({super.key});

  static const Color proColor = Color(0xFFFF9500);
  static const Color freeColor = Color(0xFF00C853);
  static const Color disabledColor = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compare Plans',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'See what you get with Pro',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 2.h),

          _buildHeader(theme),

          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                _featureRow(
                  theme,
                  icon: Icons.chat_bubble_rounded,
                  iconColor: freeColor,
                  title: 'Quick Replies',
                  freeText: '2 replies only',
                  freeEnabled: true,
                  proText: 'Unlimited replies',
                ),

                _featureRow(
                  theme,
                  icon: Icons.qr_code_rounded,
                  iconColor: const Color(0xFF2979FF),
                  title: 'QR Code Generator',
                  freeText: 'Not available',
                  freeEnabled: false,
                  proText: 'Smart QR generator',
                ),

                // ✅ QR SLOGAN (TAM İSTEDİĞİN YER)
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 4.w, 1.2.h),
                  child: Text(
                    '🎉 Print once for your card, store, or counter.\n'
                    'You can change the message anytime.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ),

                _featureRow(
                  theme,
                  icon: Icons.support_agent_rounded,
                  iconColor: const Color(0xFF8E24AA),
                  title: 'Priority Support',
                  freeText: 'Not available',
                  freeEnabled: false,
                  proText: 'Priority support',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Feature',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Free',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pro',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: proColor,
                  ),
                ),
                SizedBox(width: 1.w),
                const Icon(Icons.bolt_rounded, size: 16, color: proColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String freeText,
    required bool freeEnabled,
    required String proText,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(icon, size: 22, color: iconColor),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _valueCell(
              theme,
              enabled: freeEnabled,
              text: freeText,
              color: freeEnabled ? freeColor : disabledColor,
            ),
          ),

          Expanded(
            child: _valueCell(
              theme,
              enabled: true,
              text: proText,
              color: proColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueCell(
    ThemeData theme, {
    required bool enabled,
    required String text,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: enabled ? color : disabledColor,
          size: 20,
        ),
        SizedBox(height: 0.5.h),
        Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: enabled
                ? theme.textTheme.bodyMedium?.color
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
