import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/business_storage_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import './widgets/popular_templates_widget.dart';
import './widgets/template_card_widget.dart';
import './widgets/template_category_filter_widget.dart';
import './widgets/template_detail_dialog_widget.dart';

/// Message Templates Screen - Pre-built business message templates for WhatsApp
/// Users can select templates, customize text, and save as quick replies
class MessageTemplatesScreen extends StatefulWidget {
  const MessageTemplatesScreen({super.key});

  @override
  State<MessageTemplatesScreen> createState() => _MessageTemplatesScreenState();
}

class _MessageTemplatesScreenState extends State<MessageTemplatesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // User data
  Map<String, dynamic> _userData = {
    "userName": "Business Owner",
    "businessName": "Your Business",
    "userImageUrl": "",
    "isPro": true,
  };

  // State management
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Categories for filtering
  final List<String> _categories = [
    'All',
    'Greetings',
    'Appointments',
    'Promotions',
    'Follow-ups',
    'Customer Service',
    'Seasonal',
  ];

  // Mock template data
  final List<Map<String, dynamic>> _allTemplates = [
    {
      "id": 1,
      "title": "Welcome Message",
      "message":
          "Hello! Welcome to [Business Name]. We're excited to serve you. How can we help you today?",
      "category": "Greetings",
      "usageCount": 156,
      "placeholders": ["Business Name"],
    },
    {
      "id": 2,
      "title": "Appointment Confirmation",
      "message":
          "Hi [Customer Name], your appointment with [Business Name] is confirmed for [Date] at [Time]. See you then!",
      "category": "Appointments",
      "usageCount": 142,
      "placeholders": ["Customer Name", "Business Name", "Date", "Time"],
    },
    {
      "id": 3,
      "title": "Special Offer",
      "message":
          "🎉 Exclusive offer for you! Get [Discount]% off on [Product/Service] at [Business Name]. Valid until [Date]. Don't miss out!",
      "category": "Promotions",
      "usageCount": 198,
      "placeholders": ["Discount", "Product/Service", "Business Name", "Date"],
    },
    {
      "id": 4,
      "title": "Order Status Update",
      "message":
          "Hi [Customer Name], your order #[Order Number] has been shipped and will arrive by [Date]. Track your order: [Tracking Link]",
      "category": "Follow-ups",
      "usageCount": 134,
      "placeholders": [
        "Customer Name",
        "Order Number",
        "Date",
        "Tracking Link",
      ],
    },
    {
      "id": 5,
      "title": "Thank You Message",
      "message":
          "Thank you for choosing [Business Name]! We appreciate your business. If you have any questions, feel free to reach out.",
      "category": "Customer Service",
      "usageCount": 187,
      "placeholders": ["Business Name"],
    },
    {
      "id": 6,
      "title": "Appointment Reminder",
      "message":
          "Reminder: You have an appointment with [Business Name] tomorrow at [Time]. Reply YES to confirm or RESCHEDULE to change.",
      "category": "Appointments",
      "usageCount": 165,
      "placeholders": ["Business Name", "Time"],
    },
    {
      "id": 7,
      "title": "Out of Office",
      "message":
          "Thanks for contacting [Business Name]. We're currently closed. Our hours are [Business Hours]. We'll respond when we're back!",
      "category": "Customer Service",
      "usageCount": 123,
      "placeholders": ["Business Name", "Business Hours"],
    },
    {
      "id": 8,
      "title": "Holiday Greetings",
      "message":
          "🎄 Happy Holidays from [Business Name]! Wishing you joy and happiness this season. Thank you for your continued support!",
      "category": "Seasonal",
      "usageCount": 89,
      "placeholders": ["Business Name"],
    },
    {
      "id": 9,
      "title": "Payment Received",
      "message":
          "Payment confirmed! Thank you [Customer Name]. Your receipt for [Amount] has been sent to your email. [Business Name]",
      "category": "Customer Service",
      "usageCount": 176,
      "placeholders": ["Customer Name", "Amount", "Business Name"],
    },
    {
      "id": 10,
      "title": "Flash Sale Alert",
      "message":
          "⚡ FLASH SALE! [Product/Service] now [Discount]% off at [Business Name]. Only [Hours] hours left! Shop now: [Link]",
      "category": "Promotions",
      "usageCount": 211,
      "placeholders": [
        "Product/Service",
        "Discount",
        "Business Name",
        "Hours",
        "Link",
      ],
    },
    {
      "id": 11,
      "title": "Feedback Request",
      "message":
          "Hi [Customer Name], how was your experience with [Business Name]? We'd love to hear your feedback: [Feedback Link]",
      "category": "Follow-ups",
      "usageCount": 98,
      "placeholders": ["Customer Name", "Business Name", "Feedback Link"],
    },
    {
      "id": 12,
      "title": "New Product Launch",
      "message":
          "🚀 Exciting news! [Business Name] just launched [Product Name]. Be the first to try it: [Link]. Limited stock available!",
      "category": "Promotions",
      "usageCount": 145,
      "placeholders": ["Business Name", "Product Name", "Link"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

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
      };
    });
  }

  List<Map<String, dynamic>> get _filteredTemplates {
    List<Map<String, dynamic>> filtered = _allTemplates;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((template) => template['category'] == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((template) {
        final title = (template['title'] as String).toLowerCase();
        final message = (template['message'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || message.contains(query);
      }).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _popularTemplates {
    final sorted = List<Map<String, dynamic>>.from(_allTemplates);
    sorted.sort(
      (a, b) => (b['usageCount'] as int).compareTo(a['usageCount'] as int),
    );
    return sorted.take(3).toList();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.splash);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showTemplateDetail(Map<String, dynamic> template) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => TemplateDetailDialogWidget(
        template: template,
        businessName: _userData['businessName'],
        onSave: (customizedMessage, category) {
          _saveAsQuickReply(customizedMessage, category);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _saveAsQuickReply(String message, String category) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 2.w),
            const Expanded(child: Text('Template saved to My Replies!')),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTemplates = _filteredTemplates;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Message Templates',
        subtitle: '${filteredTemplates.length} Templates',
        showDrawerIcon: false,
        showBackButton: true,
        isHomeScreen: false,
        actions: [
          CustomAppBarActions.searchAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSearchDialog();
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        currentRoute: AppRoutes.home,
        userName: _userData['userName'],
        userEmail: '',
        userImageUrl: _userData['userImageUrl'],
        isPro: _userData['isPro'],
        onItemTap: (route) {
          Navigator.pop(context);
          if (route != AppRoutes.home) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        onLogout: _handleLogout,
      ),
      body: Column(
        children: [
          // Category filter
          TemplateCategoryFilterWidget(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),

          // Popular templates section
          if (_selectedCategory == 'All' && _searchQuery.isEmpty)
            PopularTemplatesWidget(
              templates: _popularTemplates,
              onTemplateTap: _showTemplateDetail,
            ),

          // Templates grid
          Expanded(
            child: _filteredTemplates.isEmpty
                ? _buildEmptyState(theme)
                : GridView.builder(
                    padding: EdgeInsets.all(4.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _filteredTemplates[index];
                      return TemplateCardWidget(
                        template: template,
                        onTap: () => _showTemplateDetail(template),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search',
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
            size: 60.sp,
          ),
          SizedBox(height: 2.h),
          Text(
            'No templates found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = _searchQuery;
        return AlertDialog(
          title: const Text('Search Templates'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter keywords...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (value) {
              searchText = value;
            },
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value;
              });
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = searchText;
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}