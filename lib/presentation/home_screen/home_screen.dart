import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../models/quick_reply_model.dart';
import '../../services/business_storage_service.dart';
import '../../services/quick_replies_storage_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import './widgets/action_card_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/quick_reply_counter_widget.dart';

/// Home Screen - Primary dashboard for WhatsApp business message management
/// Displays user profile, quick reply counter, and primary action cards
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Real user data from storage
  Map<String, dynamic> _userData = {
    "userName": "Business Owner",
    "businessName": "Your Business",
    "userImageUrl": "",
    "isPro": false,
    "currentReplies": 0,
    "maxReplies": 2,
  };

  // Quick replies LIST
  List<QuickReplyModel> _quickReplies = [];
  String _whatsappPhone = '';

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
    _loadQuickReplies();
    _loadWhatsAppPhone();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBusinessData();
  }

  /// Load real business data from storage
  Future<void> _loadBusinessData() async {
    final businessName = await BusinessStorageService.getBusinessName();
    final ownerName = await BusinessStorageService.getOwnerName();
    final logoPath = await BusinessStorageService.getBusinessLogoPath();
    final isFakePremium = await BusinessStorageService.isFakePremium();

    setState(() {
      _userData = {
        "userName": ownerName,
        "businessName": businessName,
        "userImageUrl": logoPath ?? "",
        "isPro": isFakePremium,
        "currentReplies": _quickReplies.length,
        "maxReplies": isFakePremium ? 999 : 2,
      };
    });
  }

  /// Load quick replies LIST from persistent storage
  Future<void> _loadQuickReplies() async {
    final replies = await QuickRepliesStorageService.loadQuickReplies();
    setState(() {
      _quickReplies = replies;
      _userData["currentReplies"] = replies.length;
    });
  }

  /// Load WhatsApp phone number
  Future<void> _loadWhatsAppPhone() async {
    final phone = await BusinessStorageService.getWhatsappPhone();
    setState(() {
      _whatsappPhone = phone;
    });
  }

   /// Send quick reply via WhatsApp
Future<void> _sendViaWhatsApp(QuickReplyModel reply) async {
  try {
    final encodedMessage = Uri.encodeComponent(reply.message);

    final uri = Uri.parse(
      'https://api.whatsapp.com/send?text=$encodedMessage',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    await QuickRepliesStorageService
        .incrementUsageCount(reply.id);
  } catch (e) {
    debugPrint('WhatsApp error: $e');
  }
}

  /// Shows delete confirmation dialog
  void _showDeleteConfirmation(QuickReplyModel reply) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning_amber_rounded',
              color: theme.colorScheme.error,
              size: 24.sp,
            ),
            SizedBox(width: 2.w),
            const Text('Delete Reply'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this quick reply? This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await QuickRepliesStorageService.deleteQuickReply(reply.id);
              await _loadQuickReplies();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quick reply deleted'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Build reply dialog for add/edit
  Widget _buildReplyDialog({
    String? initialMessage,
    String? initialCategory,
    bool isEditing = false,
    required Function(String message, String category) onSave,
  }) {
    final theme = Theme.of(context);
    final categories = [
      'General',
      'Orders',
      'Support',
      'Payments',
      'Shipping',
      'Returns',
    ];
    final messageController = TextEditingController(text: initialMessage ?? '');
    String selectedCategory = initialCategory ?? categories.first;
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: Text(isEditing ? 'Edit Quick Reply' : 'New Quick Reply'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: messageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Message is required';
              }
              return null;
            },
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            items: categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              selectedCategory = value ?? categories.first;
            },
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState?.validate() ?? false) {
              final message = messageController.text;
              final category = selectedCategory;
              onSave(message, category);
              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/splash-screen');
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _handleDrawerNavigation(String route) {
    if (route == '/home-screen') {
      // Already on home screen
      return;
    }
    Navigator.pushNamed(context, route);
  }

  Future<void> _handleRefresh() async {
    await _loadQuickReplies();
    await _loadBusinessData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Home',
        showDrawerIcon: true,
        showBackButton: false,
        isHomeScreen: true,
      ),
      drawer: CustomDrawer(
        currentRoute: '/home-screen',
        userName: _userData["userName"] as String,
        userImageUrl: _userData["userImageUrl"] as String,
        isPro: _userData["isPro"] as bool,
        onItemTap: _handleDrawerNavigation,
        onLogout: _handleLogout,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Column(
                children: [
                  // Profile Header
                  ProfileHeaderWidget(
                    userName: _userData["userName"] as String,
                    businessName: _userData["businessName"] as String,
                    userImageUrl: _userData["userImageUrl"] as String,
                    greeting: _getGreeting(),
                  ),

                  SizedBox(height: 3.h),

                  // Quick Reply Counter
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: QuickReplyCounterWidget(
                      currentReplies: _quickReplies.length,
                      maxReplies: _userData["maxReplies"] as int,
                      isPro: _userData["isPro"] as bool,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Primary Action Cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        ActionCardWidget(
                          iconName: 'qr_code_2',
                          title: 'Generate QR Code',
                          description:
                              'Create QR codes for instant WhatsApp messages',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/qr-generator-screen',
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Quick Replies List or Empty State
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _quickReplies.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                CustomIconWidget(
                                  iconName: 'quickreply',
                                  color: theme.colorScheme.primary,
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No Quick Replies Yet',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Create your first quick reply to get started',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : _buildQuickRepliesList(theme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/my-replies-screen');
          _loadQuickReplies();
        },
        icon: CustomIconWidget(iconName: 'add', color: Colors.white, size: 24),
        label: Text('New Reply'),
      ),
    );
  }

  Widget _buildQuickRepliesList(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Replies',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.myReplies);
                },
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ..._quickReplies.map((reply) {
            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reply.category,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          reply.message,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    onPressed: () => _sendViaWhatsApp(reply),
                    icon: CustomIconWidget(
                      iconName: 'send',
                      color: const Color(0xFF25D366),
                      size: 20.sp,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF25D366,
                      ).withValues(alpha: 0.1),
                      padding: EdgeInsets.all(2.w),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(reply),
                    icon: CustomIconWidget(
                      iconName: 'delete',
                      color: theme.colorScheme.error,
                      size: 18.sp,
                    ),
                    style: IconButton.styleFrom(padding: EdgeInsets.all(2.w)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickReplyCard(QuickReplyModel reply, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and send button
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    reply.category,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                // Send button
                IconButton(
                  onPressed: () => _sendViaWhatsApp(reply),
                  icon: CustomIconWidget(
                    iconName: 'send',
                    color: const Color(0xFF25D366),
                    size: 20.sp,
                  ),
                  tooltip: 'Send via WhatsApp',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF25D366,
                    ).withValues(alpha: 0.1),
                    padding: EdgeInsets.all(2.w),
                  ),
                ),
              ],
            ),
          ),
          // Message content
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 3.w),
            child: Text(
              reply.message,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: theme.textTheme.bodyLarge?.color,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
