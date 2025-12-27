import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_routes.dart';

/// Custom AppBar widget for ReplyFast
/// Stable version – no nested returns, no broken Column
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showDrawerIcon;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;
  final double elevation;
  final VoidCallback? onDrawerTap;
  final VoidCallback? onBackTap;
  final bool isHomeScreen;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showDrawerIcon = true,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = false,
    this.elevation = 0,
    this.onDrawerTap,
    this.onBackTap,
    this.isHomeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      leading: leading ?? _buildLeading(context),
      title: _buildTitle(context),
      actions: actions,
    );
  }

  /// Leading widget logic
  Widget? _buildLeading(BuildContext context) {
    if (isHomeScreen && showDrawerIcon) {
      return IconButton(
        icon: const Icon(Icons.menu_rounded, size: 24),
        onPressed: onDrawerTap ?? () => Scaffold.of(context).openDrawer(),
        tooltip: 'Menu',
      );
    }

    if (showBackButton) {
      return _buildBackToHomeButton(context);
    }

    return null;
  }

  /// Back → Home button (Apple-style)
  Widget _buildBackToHomeButton(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap:
          onBackTap ??
          () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: theme.appBarTheme.foregroundColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Home',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Title builder (FIXED – no nested return)
  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    if (subtitle != null && subtitle!.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.appBarTheme.foregroundColor,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color:
                  theme.appBarTheme.foregroundColor?.withValues(alpha: 0.7),
              letterSpacing: 0.4,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: theme.appBarTheme.foregroundColor,
        letterSpacing: 0.15,
      ),
    );
  }

  @override
  Size get preferredSize =>
      subtitle != null && subtitle!.isNotEmpty
          ? const Size.fromHeight(64)
          : const Size.fromHeight(56);
}

/// ---------- ACTION HELPERS (UNCHANGED API) ----------
extension CustomAppBarActions on CustomAppBar {
  static Widget searchAction({
    required VoidCallback onPressed,
    String tooltip = 'Search',
  }) {
    return IconButton(
      icon: const Icon(Icons.search_rounded, size: 24),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  static Widget moreAction({
    required VoidCallback onPressed,
    String tooltip = 'More',
  }) {
    return IconButton(
      icon: const Icon(Icons.more_vert_rounded, size: 24),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  static Widget settingsAction({
    required VoidCallback onPressed,
    String tooltip = 'Settings',
  }) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined, size: 24),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  static Widget shareAction({
    required VoidCallback onPressed,
    String tooltip = 'Share',
  }) {
    return IconButton(
      icon: const Icon(Icons.share_outlined, size: 24),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  static Widget copyAction({
    required VoidCallback onPressed,
    String tooltip = 'Copy',
  }) {
    return IconButton(
      icon: const Icon(Icons.content_copy_rounded, size: 22),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  static Widget filterAction({
    required VoidCallback onPressed,
    String tooltip = 'Filter',
    bool isActive = false,
  }) {
    return IconButton(
      icon: Icon(
        isActive ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
        size: 24,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
