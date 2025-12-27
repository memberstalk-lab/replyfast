import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty State Widget - Displays when no replies are available
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddReply;
  final bool isSearching;

  const EmptyStateWidget({
    super.key,
    required this.onAddReply,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isSearching ? 'search_off' : 'chat_bubble_outline',
                  color: theme.colorScheme.primary,
                  size: 20.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Title
            Text(
              isSearching ? 'No Results Found' : 'No Quick Replies Yet',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.5.h),

            // Description
            Text(
              isSearching
                  ? 'Try adjusting your search or filter to find what you\'re looking for.'
                  : 'Create your first quick reply to respond to customers faster and more professionally.',
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Action button
            if (!isSearching)
              ElevatedButton.icon(
                onPressed: onAddReply,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: theme.colorScheme.onPrimary,
                  size: 18.sp,
                ),
                label: const Text('Create First Reply'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.8.h,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
