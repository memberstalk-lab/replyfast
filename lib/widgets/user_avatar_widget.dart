import 'dart:io';
import 'package:flutter/material.dart';

/// Widget for displaying user avatar images with support for local files
/// Handles both local file paths and network URLs
class UserAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  const UserAvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 64,
    this.fallbackIcon = Icons.person,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = fallbackColor ?? theme.colorScheme.primary;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(iconColor);
    }

    // Local file path
    if (imageUrl!.startsWith('/')) {
      return ClipOval(
        child: Image.file(
          File(imageUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallback(iconColor),
        ),
      );
    }

    // Network URL
    if (imageUrl!.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallback(iconColor),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    }

    // Asset image
    return ClipOval(
      child: Image.asset(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(iconColor),
      ),
    );
  }

  Widget _buildFallback(Color iconColor) {
    return Icon(fallbackIcon, size: size * 0.5, color: iconColor);
  }
}
