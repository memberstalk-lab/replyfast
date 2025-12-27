import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './user_avatar_widget.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;
  final String userName;
  final String? userEmail;
  final String? userImageUrl;
  final bool isPro;
  final Function(String route) onItemTap;

  // 🔧 GERİ EKLENDİ – AMA KULLANILMIYOR
  final VoidCallback? onLogout;

  const CustomDrawer({
    super.key,
    required this.currentRoute,
    required this.userName,
    this.userEmail,
    this.userImageUrl,
    required this.isPro,
    required this.onItemTap,
    this.onLogout, // ⚠️ sadece uyumluluk
  });

  static const String _privacyText = '''
Privacy Policy

This app stores all data locally on your device.
No personal data is collected or stored on servers.

support@replyfast.site
''';

  static const String _termsText = '''
Terms of Service

• You are responsible for message usage
• Message delivery depends on WhatsApp
• App is provided "as is"

support@replyfast.site
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              padding: EdgeInsets.all(4.w),
              color: theme.colorScheme.primary.withAlpha(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withAlpha(38),
                    ),
                    child: UserAvatarWidget(
                      imageUrl: userImageUrl,
                      size: 52,
                      fallbackIcon: Icons.store,
                      fallbackColor: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isPro)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ===== MENU =====
            _menuItem(
              context,
              icon: Icons.home,
              color: Colors.blue,
              title: 'Home',
              route: '/home-screen',
            ),
            _menuItem(
              context,
              icon: Icons.message,
              color: Colors.green,
              title: 'My Replies',
              route: '/my-replies-screen',
            ),
            _menuItem(
              context,
              icon: Icons.qr_code,
              color: Colors.purple,
              title: 'QR Generator',
              route: '/qr-generator-screen',
            ),
            _menuItem(
              context,
              icon: Icons.settings,
              color: Colors.teal,
              title: 'Settings',
              route: '/settings-screen',
            ),

            // ===== UPGRADE TO PREMIUM (FREE USERS ONLY) =====
            if (!isPro)
              _menuItem(
                context,
                icon: Icons.workspace_premium,
                color: Colors.orange,
                title: 'Upgrade to Premium',
                route: '/upgrade-to-pro-screen',
              ),

            const Divider(height: 24),

            _menuAction(
              context,
              icon: Icons.privacy_tip,
              color: Colors.indigo,
              title: 'Privacy Policy',
              onTap: () =>
                  _showInfoSheet(context, 'Privacy Policy', _privacyText),
            ),
            _menuAction(
              context,
              icon: Icons.description,
              color: Colors.deepPurple,
              title: 'Terms of Service',
              onTap: () =>
                  _showInfoSheet(context, 'Terms of Service', _termsText),
            ),

            const Spacer(),

            // ❌ LOGOUT YOK – BİLİNÇLİ
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String route,
  }) {
    final bool selected = currentRoute == route;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      tileColor: selected
          ? Theme.of(context).colorScheme.primary.withAlpha(26)
          : null,
      onTap: () {
        Navigator.pop(context);
        onItemTap(route);
      },
    );
  }

  Widget _menuAction(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showInfoSheet(BuildContext context, String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
