import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

import '../../../widgets/custom_icon_widget.dart';

/// Widget for business logo upload with image preview
class LogoUploadWidget extends StatelessWidget {
  final String? logoPath;
  final VoidCallback onPickImage;

  const LogoUploadWidget({
    super.key,
    required this.logoPath,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: onPickImage,
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outline, width: 2),
          ),
          child: logoPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(File(logoPath!), fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add_photo_alternate',
                      color: theme.colorScheme.primary,
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Upload Logo',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
