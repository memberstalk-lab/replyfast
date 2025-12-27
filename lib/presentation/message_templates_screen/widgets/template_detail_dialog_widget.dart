import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Template Detail Dialog Widget - Full template view with customization
class TemplateDetailDialogWidget extends StatefulWidget {
  final Map<String, dynamic> template;
  final String businessName;
  final Function(String message, String category) onSave;

  const TemplateDetailDialogWidget({
    super.key,
    required this.template,
    required this.businessName,
    required this.onSave,
  });

  @override
  State<TemplateDetailDialogWidget> createState() =>
      _TemplateDetailDialogWidgetState();
}

class _TemplateDetailDialogWidgetState
    extends State<TemplateDetailDialogWidget> {
  late TextEditingController _messageController;
  late String _customizedMessage;
  final Map<String, TextEditingController> _placeholderControllers = {};

  @override
  void initState() {
    super.initState();
    _customizedMessage = widget.template['message'] as String;
    _messageController = TextEditingController(text: _customizedMessage);

    // Initialize placeholder controllers
    final placeholders = widget.template['placeholders'] as List<dynamic>;
    for (final placeholder in placeholders) {
      final key = placeholder as String;
      _placeholderControllers[key] = TextEditingController(
        text: key == 'Business Name' ? widget.businessName : '',
      );
    }

    // Auto-replace Business Name placeholder
    if (placeholders.contains('Business Name')) {
      _updatePlaceholder('Business Name', widget.businessName);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    for (final controller in _placeholderControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updatePlaceholder(String placeholder, String value) {
    setState(() {
      _customizedMessage =
          _customizedMessage.replaceAll('[$placeholder]', value);
      _messageController.text = _customizedMessage;
    });
  }

  void _resetTemplate() {
    HapticFeedback.lightImpact();
    setState(() {
      _customizedMessage = widget.template['message'] as String;
      _messageController.text = _customizedMessage;
      for (final entry in _placeholderControllers.entries) {
        if (entry.key == 'Business Name') {
          entry.value.text = widget.businessName;
        } else {
          entry.value.clear();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.template['title'] as String;
    final category = widget.template['category'] as String;
    final placeholders = widget.template['placeholders'] as List<dynamic>;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.textTheme.bodyMedium?.color,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message preview
                    Text(
                      'Message Preview',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _customizedMessage,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.textTheme.bodyMedium?.color,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Character counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Character Count',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          '${_customizedMessage.length} characters',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Placeholder customization
                    if (placeholders.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customize Placeholders',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _resetTemplate,
                            icon: Icon(Icons.refresh_rounded, size: 16.sp),
                            label: const Text('Reset'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      ...placeholders.map((placeholder) {
                        final key = placeholder as String;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: TextField(
                            controller: _placeholderControllers[key],
                            decoration: InputDecoration(
                              labelText: key,
                              hintText: 'Enter $key',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.5.h,
                              ),
                            ),
                            onChanged: (value) {
                              _updatePlaceholder(key, value);
                            },
                          ),
                        );
                      }).toList(),
                    ],

                    // Edit message directly
                    Text(
                      'Edit Message',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Edit your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.all(3.w),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _customizedMessage = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onSave(_customizedMessage, category);
                      },
                      icon: Icon(Icons.save_rounded, size: 18.sp),
                      label: Text(
                        'Save to My Replies',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
}