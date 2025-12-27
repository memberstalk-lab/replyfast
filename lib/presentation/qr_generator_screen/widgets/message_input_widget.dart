import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Message Input Widget - Multiline text input for message content
/// IMPORTANT: Message changes do NOT regenerate QR code
/// QR code is FIXED and never changes - message is UI-only
class MessageInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String)? onChanged;

  const MessageInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final characterCount = controller.text.length;
    final maxCharacters = 500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            CustomIconWidget(
              iconName: 'edit_note',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Message Content',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),

        // Message Input Field
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focusNode.hasFocus
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 6,
            maxLength: maxCharacters,
            textInputAction: TextInputAction.done,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText:
                  'Enter your message here...\n\nNote: This message is for your reference only. The QR code will always link to the same fixed URL.',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(4.w),
              counterText: '',
            ),
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: 1.h),

        // Character Counter and Tips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Info Message
            Expanded(
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      'Message is UI-only, QR stays the same',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 10.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            // Character Counter
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: characterCount > maxCharacters * 0.9
                    ? theme.colorScheme.error.withValues(alpha: 0.1)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$characterCount/$maxCharacters',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: characterCount > maxCharacters * 0.9
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
