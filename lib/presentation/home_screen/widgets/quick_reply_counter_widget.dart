import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick reply counter card showing current saved replies with progress indicator
class QuickReplyCounterWidget extends StatelessWidget {
  final int currentReplies;
  final int maxReplies;
  final bool isPro;

  const QuickReplyCounterWidget({
    super.key,
    required this.currentReplies,
    required this.maxReplies,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentReplies / maxReplies;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'chat_bubble',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Quick Replies',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (isPro)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFF9500),
                          Color(0xFFFF9500).withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'bolt',
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'PRO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),

            // Reply Count
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currentReplies',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 2.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Text(
                    '/ $maxReplies ${isPro ? 'unlimited' : 'replies'}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Progress Bar
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 8,
              percent: progress > 1.0 ? 1.0 : progress,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              progressColor: theme.colorScheme.primary,
              barRadius: Radius.circular(4),
              animation: true,
              animationDuration: 1000,
            ),
            SizedBox(height: 1.h),

            // Status Text
            Text(
              isPro
                  ? 'Unlimited replies available'
                  : currentReplies >= maxReplies
                  ? 'Limit reached - Upgrade to Pro for unlimited'
                  : '${maxReplies - currentReplies} replies remaining',
              style: theme.textTheme.bodySmall?.copyWith(
                color: currentReplies >= maxReplies && !isPro
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
