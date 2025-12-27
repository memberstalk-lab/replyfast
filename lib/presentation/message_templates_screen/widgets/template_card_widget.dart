import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Template Card Widget - Displays individual template preview
class TemplateCardWidget extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onTap;

  const TemplateCardWidget({
    super.key,
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = template['title'] as String;
    final message = template['message'] as String;
    final category = template['category'] as String;
    final usageCount = template['usageCount'] as int;

    // Get first 2 lines of message for preview
    final messageLines = message.split('\n');
    final previewText = messageLines.length > 2
        ? '${messageLines[0]}\n${messageLines[1]}...'
        : message.length > 80
        ? '${message.substring(0, 80)}...'
        : message;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category badge
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Message preview
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Text(
                  previewText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Footer with category and usage
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        category,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(category),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Usage count
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.6,
                    ),
                    size: 12.sp,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '$usageCount',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Greetings':
        return const Color(0xFF25D366);
      case 'Appointments':
        return const Color(0xFF007AFF);
      case 'Promotions':
        return const Color(0xFFFF9500);
      case 'Follow-ups':
        return const Color(0xFF5856D6);
      case 'Customer Service':
        return const Color(0xFF34C759);
      case 'Seasonal':
        return const Color(0xFFFF3B30);
      default:
        return const Color(0xFF8E8E93);
    }
  }
}
