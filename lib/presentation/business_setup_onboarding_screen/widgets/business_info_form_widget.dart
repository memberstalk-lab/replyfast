import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget for collecting basic business information
class BusinessInfoFormWidget extends StatelessWidget {
  final TextEditingController businessNameController;
  final TextEditingController ownerNameController;

  const BusinessInfoFormWidget({
    super.key,
    required this.businessNameController,
    required this.ownerNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: businessNameController,
          decoration: InputDecoration(
            labelText: 'Business Name *',
            hintText: 'Enter your business name',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter business name';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: ownerNameController,
          decoration: InputDecoration(
            labelText: 'Owner Name *',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter owner name';
            }
            return null;
          },
        ),
      ],
    );
  }
}
