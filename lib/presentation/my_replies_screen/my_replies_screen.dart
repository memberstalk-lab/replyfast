import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../models/quick_reply_model.dart';
import '../../services/business_storage_service.dart';
import '../../services/quick_replies_storage_service.dart';
import '../../widgets/custom_drawer.dart';
import './widgets/add_reply_dialog_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/empty_state_widget.dart';

class MyRepliesScreen extends StatefulWidget {
  const MyRepliesScreen({super.key});

  @override
  State<MyRepliesScreen> createState() => _MyRepliesScreenState();
}

class _MyRepliesScreenState extends State<MyRepliesScreen> {
  bool _isPro = false;
  final int _maxReplies = 2;
  String _whatsappPhone = '';

  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<QuickReplyModel> _allReplies = [];

  final List<String> _categories = [
    'All',
    'General',
    'Orders',
    'Support',
    'Payments',
    'Shipping',
    'Returns',
  ];

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
    _loadWhatsAppPhone();
    _loadQuickReplies();
  }

  Future<void> _loadPremiumStatus() async {
    final isFakePremium = await BusinessStorageService.isFakePremium();
    setState(() => _isPro = isFakePremium);
  }

  Future<void> _loadWhatsAppPhone() async {
    final phone = await BusinessStorageService.getWhatsappPhone();
    setState(() => _whatsappPhone = phone);
  }

  Future<void> _loadQuickReplies() async {
    final replies = await QuickRepliesStorageService.loadQuickReplies();
    setState(() => _allReplies = replies);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredReplies = _getFilteredReplies();
    final replyCount = _allReplies.length;
    final remainingSlots = _isPro ? null : (_maxReplies - replyCount);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: CustomDrawer(
        currentRoute: '/my-replies-screen',
        userName: 'Business Owner',
        isPro: _isPro,
        onItemTap: (route) {
          Navigator.pushReplacementNamed(context, route);
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/splash-screen');
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _canAddReply() ? _showAddReplyDialog : _showUpgradePrompt,
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 20.sp,
        ),
        label: Text(
          'Create Quick Reply',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          // 🍏 SETTINGS STYLE HEADER (BİREBİR)
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
            expandedHeight: 130,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: _showSearchDialog,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              title: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF00B0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  'My Replies',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // FILTERS
          SliverToBoxAdapter(
            child: CategoryFilterWidget(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (c) {
                setState(() => _selectedCategory = c);
              },
            ),
          ),

          // STORAGE INDICATOR (SYNTAX SAFE)
          if (!_isPro && remainingSlots != null) ...[
            SliverToBoxAdapter(
              child: _buildStorageIndicator(theme, remainingSlots),
            ),
          ],

          // CONTENT
          if (filteredReplies.isEmpty) ...[
            SliverToBoxAdapter(
              child: EmptyStateWidget(
                onAddReply: _showAddReplyDialog,
                isSearching: _searchQuery.isNotEmpty,
              ),
            ),
          ] else ...[
            SliverList.separated(
              itemCount: filteredReplies.length,
              separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
              itemBuilder: (context, index) {
                final reply = filteredReplies[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _buildReplyCard(reply, theme),
                );
              },
            ),
          ],

          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  List<QuickReplyModel> _getFilteredReplies() {
    var filtered = _allReplies;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((r) => r.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (r) => r.message.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  bool _canAddReply() => _isPro || _allReplies.length < _maxReplies;

  Widget _buildReplyCard(QuickReplyModel reply, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(26),
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
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: theme.colorScheme.primary,
                    size: 18.sp,
                  ),
                  onPressed: () => _showEditReplyDialog(reply),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'delete',
                    color: theme.colorScheme.error,
                    size: 18.sp,
                  ),
                  onPressed: () => _showDeleteConfirmation(reply),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'send',
                    color: const Color(0xFF25D366),
                    size: 20.sp,
                  ),
                  onPressed: () => _sendViaWhatsApp(reply),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              reply.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageIndicator(ThemeData theme, int remainingSlots) {
    final isLow = remainingSlots <= 3;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isLow
            ? theme.colorScheme.error.withAlpha(26)
            : theme.colorScheme.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isLow ? Icons.warning_amber_rounded : Icons.info_outline,
            color: isLow ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              '$remainingSlots slots remaining',
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
          if (isLow)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/upgrade-to-pro-screen');
              },
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  // ================= DIALOGS =================

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String temp = _searchQuery;
        return AlertDialog(
          title: const Text('Search Replies'),
          content: TextField(autofocus: true, onChanged: (v) => temp = v),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = '');
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = temp);
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showAddReplyDialog() {
    final cats = _categories.where((c) => c != 'All').toList();
    showDialog(
      context: context,
      builder: (_) => AddReplyDialogWidget(
        categories: cats,
        onSave: (message, category) async {
          await QuickRepliesStorageService.addQuickReply(message, category);
          _loadQuickReplies();
        },
      ),
    );
  }

  void _showEditReplyDialog(QuickReplyModel reply) {
    final cats = _categories.where((c) => c != 'All').toList();
    showDialog(
      context: context,
      builder: (_) => AddReplyDialogWidget(
        categories: cats,
        initialMessage: reply.message,
        initialCategory: reply.category,
        isEditing: true,
        onSave: (message, category) async {
          await QuickRepliesStorageService.updateQuickReply(
            reply.id,
            message,
            category,
          );
          _loadQuickReplies();
        },
      ),
    );
  }

  void _showDeleteConfirmation(QuickReplyModel reply) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Reply'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await QuickRepliesStorageService.deleteQuickReply(reply.id);
              _loadQuickReplies();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUpgradePrompt() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: const Text('Upgrade to unlock unlimited replies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/upgrade-to-pro-screen');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

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
}
