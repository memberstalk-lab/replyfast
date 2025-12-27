import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/user_avatar_widget.dart';

/// Profile header widget displaying user information and greeting
/// Shows user profile image, name, business name, and time-based greeting
class ProfileHeaderWidget extends StatelessWidget {
  final String userName;
  final String businessName;
  final String? userImageUrl;
  final String greeting;

  const ProfileHeaderWidget({
    super.key,
    required this.userName,
    required this.businessName,
    this.userImageUrl,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          _buildProfileImage(theme),

          SizedBox(width: 4.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.3.h),
                Text(
                  businessName,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: UserAvatarWidget(
        imageUrl: userImageUrl,
        size: 60,
        fallbackIcon: Icons.person,
        fallbackColor: Colors.white,
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme) {
    if (userImageUrl == null || userImageUrl!.isEmpty) {
      return _buildPlaceholder(theme);
    }

    // Check if it's a local file path
    if (userImageUrl!.startsWith('/')) {
      return Image.file(
        File(userImageUrl!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
      );
    }

    // Network image
    return Image.network(
      userImageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
            strokeWidth: 2,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: Center(
        child: CustomIconWidget(
          iconName: 'person',
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
