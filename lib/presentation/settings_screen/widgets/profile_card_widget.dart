import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/user_avatar_widget.dart';

/// Profile card widget displaying user information with edit action
class ProfileCardWidget extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userImageUrl;
  final VoidCallback onEditProfile;

  const ProfileCardWidget({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userImageUrl,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: UserAvatarWidget(
              imageUrl: userImageUrl,
              size: 64,
              fallbackIcon: Icons.person,
              fallbackColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),

          // User Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEditProfile,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: CustomIconWidget(
                  iconName: 'edit',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
