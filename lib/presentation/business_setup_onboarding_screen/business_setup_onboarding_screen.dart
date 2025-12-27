import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/business_storage_service.dart';
import './widgets/business_info_form_widget.dart';
import './widgets/logo_upload_widget.dart';

/// Business Setup Onboarding Screen
/// Guides new users through essential business information collection on first app launch
class BusinessSetupOnboardingScreen extends StatefulWidget {
  const BusinessSetupOnboardingScreen({super.key});

  @override
  State<BusinessSetupOnboardingScreen> createState() =>
      _BusinessSetupOnboardingScreenState();
}

class _BusinessSetupOnboardingScreenState
    extends State<BusinessSetupOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _whatsappController = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.TR, nsn: ''),
  );
  final _businessAddressController = TextEditingController();
  final _workingHoursController = TextEditingController();

  String? _logoPath;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _whatsappController.dispose();
    _businessAddressController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _businessNameController.text.isNotEmpty &&
          _ownerNameController.text.isNotEmpty;
    } else if (_currentStep == 1) {
      // WhatsApp phone and address are REQUIRED
      final phoneNumber = _whatsappController.value;
      return phoneNumber.nsn.isNotEmpty &&
          phoneNumber.nsn.length >= 10 &&
          _businessAddressController.text.trim().isNotEmpty;
    } else if (_currentStep == 2) {
      return _workingHoursController.text.isNotEmpty;
    }
    return true;
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _completeSetup();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeSetup() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      // Save all business data using the existing method
      await BusinessStorageService.saveBusinessData(
        businessName: _businessNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        whatsappPhone:
            '+${_whatsappController.value.countryCode}${_whatsappController.value.nsn}',
        businessAddress: _businessAddressController.text.trim(),
        businessWorkingHours: _workingHoursController.text.trim(),
        businessLogoPath: _logoPath,
      );

      if (mounted) {
        // Navigate to Home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save business data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _skipSetup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Skip Setup?'),
        content: Text(
          'You can complete your business setup later from Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Skip'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BusinessStorageService.setOnboardingComplete(true);
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  CustomIconWidget(
                    iconName: 'business_center',
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Welcome to Reply Fast',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Let\'s set up your business',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Progress Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        width: 15.w,
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // Step 0: Basic Info
                      if (_currentStep == 0) ...[
                        Text(
                          'Business Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Tell us about your business',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        BusinessInfoFormWidget(
                          businessNameController: _businessNameController,
                          ownerNameController: _ownerNameController,
                        ),
                      ],

                      // Step 1: Contact Info (WhatsApp and Address REQUIRED)
                      if (_currentStep == 1) ...[
                        Text(
                          'Contact Information',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'How can customers reach you?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // WhatsApp Phone Number (REQUIRED)
                        PhoneFormField(
                          controller: _whatsappController,
                          decoration: InputDecoration(
                            labelText: 'WhatsApp Phone Number *',
                            hintText: '+905XXXXXXXXX',
                            helperText:
                                'Required - This number will be used for QR code and direct WhatsApp chat',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: PhoneValidator.compose([
                            PhoneValidator.required(
                              context,
                              errorText: 'WhatsApp phone number is required',
                            ),
                            PhoneValidator.validMobile(
                              context,
                              errorText: 'Please enter a valid mobile number',
                            ),
                          ]),
                          countrySelectorNavigator:
                              const CountrySelectorNavigator.bottomSheet(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                        SizedBox(height: 2.h),

                        // Business Address (REQUIRED)
                        TextFormField(
                          controller: _businessAddressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Business Address *',
                            hintText: 'Enter your business location',
                            helperText: 'Required - Your business address',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Business address is required';
                            }
                            return null;
                          },
                        ),
                      ],

                      // Step 2: Working Hours
                      if (_currentStep == 2) ...[
                        Text(
                          'Working Hours',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'When are you available?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        TextFormField(
                          controller: _workingHoursController,
                          decoration: InputDecoration(
                            labelText: 'Working Hours *',
                            hintText: 'e.g., Mon-Fri 9:00 AM - 6:00 PM',
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter working hours';
                            }
                            return null;
                          },
                        ),
                      ],

                      // Step 3: Logo Upload
                      if (_currentStep == 3) ...[
                        Text(
                          'Business Logo',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Upload your business logo (optional)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        LogoUploadWidget(
                          logoPath: _logoPath,
                          onPickImage: _pickImage,
                        ),
                      ],

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    LinearProgressIndicator()
                  else
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              child: Text('Back'),
                            ),
                          ),
                        if (_currentStep > 0) SizedBox(width: 2.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            child: Text(
                              _currentStep == 3 ? 'Complete Setup' : 'Next',
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 2.h),
                  TextButton(
                    onPressed: _skipSetup,
                    child: Text('Skip for now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
