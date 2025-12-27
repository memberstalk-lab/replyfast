import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../core/app_export.dart';
import '../../services/business_storage_service.dart';
import '../../widgets/custom_drawer.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/message_history_widget.dart';
import './widgets/message_input_widget.dart';
import './widgets/premium_gate_widget.dart';
import './widgets/qr_code_display_widget.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  String _currentMessage =
      'Hello! Thanks for reaching out. How can we help you today?';

  bool _isMessageHistoryExpanded = false;
  bool _isPremium = false;
  bool _isLoading = true;

  static const String _fixedQrData = 'https://replyfast.site/qr';

  final List<Map<String, dynamic>> _messageHistory = [];
  String _businessName = '';

  @override
  void initState() {
    super.initState();
    _messageController.text = _currentMessage;
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    final businessName = await BusinessStorageService.getBusinessName();
    final isPremium = await BusinessStorageService.isFakePremium();

    if (!mounted) return;
    setState(() {
      _businessName = businessName;
      _isPremium = isPremium;
      _isLoading = false;
    });
  }

  // 🔥 SERVER SAVE (SMART QR)
  Future<bool> _saveMessageToServer(String message) async {
    try {
      final res = await http.post(
        Uri.parse('https://replyfast.site/qr/save.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _handleSave() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    final ok = await _saveMessageToServer(message);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Try again.')),
      );
      return;
    }

    setState(() {
      _currentMessage = message;
      _messageHistory.insert(0, {
        'message': message,
        'timestamp': DateTime.now(),
      });
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message saved. QR stays the same.')),
    );
  }

  void _handleMessageSelect(String message) {
    setState(() {
      _currentMessage = message;
      _messageController.text = message;
      _isMessageHistoryExpanded = false;
    });
    HapticFeedback.lightImpact();
  }

  void _handleCopyLink() {
    Clipboard.setData(const ClipboardData(text: _fixedQrData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR link copied')),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: CustomDrawer(
        currentRoute: AppRoutes.qrGenerator,
        userName: _businessName,
        isPro: _isPremium,
        onItemTap: (route) {
          if (route != AppRoutes.qrGenerator) {
            Navigator.pushNamed(context, route);
          }
        },
        onLogout: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.businessSetupOnboarding,
            (_) => false,
          );
        },
      ),
      body: PremiumGateWidget(
        isPremium: _isPremium,
        child: CustomScrollView(
          slivers: [
            // 🍏 SETTINGS STYLE HEADER (FIXED – 1 LINE)
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              leadingWidth: 90,
              leading: InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (_) => false,
                  );
                },
                child: Row(
                  children: const [
                    SizedBox(width: 12),
                    Icon(Icons.arrow_back_ios, size: 18),
                    SizedBox(width: 4),
                    Text('Home'),
                  ],
                ),
              ),
              expandedHeight: 110,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
                title: ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFF00C853),
                        Color(0xFF00B0FF),
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'QR Code Generator',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // 🔽 CONTENT (ORJİNAL)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QrCodeDisplayWidget(
                      qrData: _fixedQrData,
                      onLongPress: _handleCopyLink,
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '🎉 You only need to print this QR once.\nYou can change the message anytime.',
                      ),
                    ),
                    SizedBox(height: 2.h),
                    MessageInputWidget(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      onChanged: (v) => setState(() => _currentMessage = v),
                    ),
                    SizedBox(height: 2.h),
                    ActionButtonsWidget(
                      onSave: _handleSave,
                      onShare: _handleCopyLink,
                    ),
                    SizedBox(height: 2.h),
                    MessageHistoryWidget(
                      messageHistory: _messageHistory,
                      onMessageSelect: _handleMessageSelect,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
