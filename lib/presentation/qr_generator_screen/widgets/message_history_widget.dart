import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Message History Widget - Shows previously generated QR messages
/// Allows quick selection of past messages for reuse
class MessageHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> messageHistory;
  final Function(String) onMessageSelect;

  const MessageHistoryWidget({
    super.key,
    required this.messageHistory,
    required this.onMessageSelect,
  });

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Messages',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Tap to use',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messageHistory.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, index) {
              final message = messageHistory[index];
              return InkWell(
                onTap: () => onMessageSelect(message['message'] as String),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Preview
                      Text(
                        message['message'] as String,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),

                      // Metadata
                      Row(
                        children: [
                          // Timestamp
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _formatTimestamp(message['timestamp'] as DateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(width: 3.w),

                          // Usage Count
                          CustomIconWidget(
                            iconName: 'visibility',
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${message['usageCount']} uses',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: 10.sp,
                            ),
                          ),
                          const Spacer(),

                          // Select Indicator
                          CustomIconWidget(
                            iconName: 'arrow_forward_ios',
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
