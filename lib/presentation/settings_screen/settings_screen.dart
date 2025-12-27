import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_export.dart';
import '../../services/business_storage_service.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/user_avatar_widget.dart';
import './widgets/profile_card_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = "Business Owner";
  String _userEmail = "";
  String? _userImageUrl;
  String _businessName = "Your Business";
  String _businessAddress = "";
  String _businessWorkingHours = "";

  bool _isPro = true;
  bool _isLoading = true;

  final ImagePicker _imagePicker = ImagePicker();

  final String _appVersion = "1.0.0";
  final String _buildNumber = "December 2025";

  static const String _supportEmail = 'support@replyfast.site';

  static const String _helpText = '''
• Create and save quick replies.
• Manage replies from "My Replies".
• Send replies directly via WhatsApp.
''';

  static const String _privacyText = '''
This app stores all data locally on your device.
No personal data is collected or stored on servers.
''';

  static const String _termsText = '''
This app is provided "as is".
You are responsible for message usage.
''';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final businessName = await BusinessStorageService.getBusinessName();
    final ownerName = await BusinessStorageService.getOwnerName();
    final address = await BusinessStorageService.getBusinessAddress();
    final hours = await BusinessStorageService.getBusinessWorkingHours();
    final logoPath = await BusinessStorageService.getBusinessLogoPath();
    final isPro = await BusinessStorageService.isFakePremium();

    if (!mounted) return;

    setState(() {
      _userName = ownerName.isNotEmpty ? ownerName : "Business Owner";
      _businessName = businessName.isNotEmpty ? businessName : "Your Business";
      _businessAddress = address;
      _businessWorkingHours = hours;
      _userImageUrl = logoPath;
      _isPro = isPro;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: CustomDrawer(
        currentRoute: '/settings-screen',
        userName: _userName,
        userEmail: _userEmail,
        userImageUrl: _userImageUrl,
        isPro: _isPro,
        onItemTap: (route) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route);
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            leadingWidth: 90,
            leading: InkWell(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home-screen',
                  (route) => false,
                );
              },
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_back_ios, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Home',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            expandedHeight: 130,
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
                  'Settings',
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

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),

                ProfileCardWidget(
                  userName: _userName,
                  userEmail: _userEmail,
                  userImageUrl: _userImageUrl,
                  onEditProfile: _handleEditProfile,
                ),

                SettingsSectionWidget(
                  title: 'SUPPORT',
                  children: [
                    SettingsItemWidget(
                      iconName: 'help',
                      title: 'Help',
                      subtitle: 'How to use the app',
                      onTap: () =>
                          _showInfoSheet(title: 'Help', body: _helpText),
                    ),
                    SettingsItemWidget(
                      iconName: 'support_agent',
                      title: 'Contact Support',
                      subtitle: _supportEmail,
                      onTap: () => _showInfoSheet(
                        title: 'Contact Support',
                        body: _supportEmail,
                        showCopyEmail: true,
                      ),
                    ),
                    SettingsItemWidget(
                      iconName: 'info',
                      title: 'App Version',
                      subtitle: '$_appVersion • $_buildNumber',
                      showDivider: false,
                    ),
                  ],
                ),

                SettingsSectionWidget(
                  title: 'LEGAL',
                  children: [
                    SettingsItemWidget(
                      iconName: 'privacy_tip',
                      title: 'Privacy Policy',
                      onTap: () => _showInfoSheet(
                        title: 'Privacy Policy',
                        body: _privacyText,
                      ),
                    ),
                    SettingsItemWidget(
                      iconName: 'description',
                      title: 'Terms of Service',
                      onTap: () => _showInfoSheet(
                        title: 'Terms of Service',
                        body: _termsText,
                      ),
                      showDivider: false,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleEditProfile() {
    HapticFeedback.lightImpact();
    _showEditProfileDialog();
  }

  void _showEditProfileDialog() {
    final businessNameController = TextEditingController(text: _businessName);
    final ownerNameController = TextEditingController(text: _userName);
    final addressController = TextEditingController(text: _businessAddress);
    final hoursController = TextEditingController(text: _businessWorkingHours);
    final whatsappPhoneController = TextEditingController();
    String? selectedImagePath = _userImageUrl;

    // Pre-fill WhatsApp phone number
    BusinessStorageService.getWhatsappPhone().then((phone) {
      whatsappPhoneController.text = phone;
    });

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final pickedFile = await _imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setDialogState(() {
                        selectedImagePath = pickedFile.path;
                      });
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        dialogContext,
                      ).colorScheme.primary.withAlpha(26),
                      border: Border.all(
                        color: Theme.of(
                          dialogContext,
                        ).colorScheme.primary.withAlpha(77),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: UserAvatarWidget(
                            imageUrl: selectedImagePath,
                            size: 80,
                            fallbackIcon: Icons.camera_alt,
                            fallbackColor: Theme.of(
                              dialogContext,
                            ).colorScheme.primary,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                dialogContext,
                              ).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap to change photo',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: businessNameController,
                  decoration: InputDecoration(
                    labelText: 'Business Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: ownerNameController,
                  decoration: InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Business Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: hoursController,
                  decoration: InputDecoration(
                    labelText: 'Working Hours',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: whatsappPhoneController,
                  decoration: InputDecoration(
                    labelText: 'WhatsApp Phone Number',
                    hintText: '+905XXXXXXXXX',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await BusinessStorageService.saveBusinessData(
                  businessName: businessNameController.text,
                  ownerName: ownerNameController.text,
                  whatsappPhone: whatsappPhoneController.text,
                  businessAddress: addressController.text,
                  businessWorkingHours: hoursController.text,
                  businessLogoPath: selectedImagePath,
                );
                Navigator.pop(dialogContext);
                await _loadUserData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully')),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet({
    required String title,
    required String body,
    bool showCopyEmail = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(body),
            const SizedBox(height: 12),
            if (showCopyEmail)
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: _supportEmail));
                  Navigator.pop(context);
                },
                child: const Text('Copy Email'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
