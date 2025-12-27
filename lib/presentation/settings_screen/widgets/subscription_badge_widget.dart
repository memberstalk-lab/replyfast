import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

/// Subscription status badge widget
class SubscriptionBadgeWidget extends StatelessWidget {
  final bool isPro;

  const SubscriptionBadgeWidget({super.key, required this.isPro});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isPro
            ? const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFF9500)],
              )
            : null,
        color: isPro ? null : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isPro ? null : Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPro)
            CustomIconWidget(iconName: 'bolt', color: Colors.white, size: 14),
          if (isPro) const SizedBox(width: 4),
          Text(
            isPro ? 'PRO' : 'FREE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPro ? Colors.white : theme.textTheme.bodyMedium?.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
