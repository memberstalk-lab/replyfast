import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Testimonials Widget
/// Social proof section with business testimonials, star ratings, and customer photos
class TestimonialsWidget extends StatelessWidget {
  const TestimonialsWidget({super.key});

  // Testimonial data
  final List<Map<String, dynamic>> _testimonials = const [
    {
      "name": "Sarah Johnson",
      "business": "Boutique Owner",
      "rating": 5,
      "testimonial":
          "Reply Fast Pro transformed how I handle customer inquiries. I can respond 10x faster now!",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_14da91c34-1763294780479.png",
      "semanticLabel":
          "Professional headshot of a woman with shoulder-length brown hair wearing a navy blazer against a neutral background",
    },
    {
      "name": "Michael Chen",
      "business": "Restaurant Manager",
      "rating": 5,
      "testimonial":
          "The unlimited quick replies feature is a game-changer. My response time improved dramatically.",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1ed9501a6-1763292467465.png",
      "semanticLabel":
          "Professional headshot of an Asian man with short black hair wearing a white shirt against a light gray background",
    },
    {
      "name": "Emily Rodriguez",
      "business": "Salon Owner",
      "rating": 5,
      "testimonial":
          "Best investment for my business! The QR codes help customers reach me instantly.",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_162a57531-1763296100992.png",
      "semanticLabel":
          "Professional headshot of a Hispanic woman with long dark hair wearing a teal blouse against a white background",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trusted by Businesses',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Join thousands of satisfied business owners',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 2.h),

          // Testimonials List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _testimonials.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final testimonial = _testimonials[index];
              return _buildTestimonialCard(
                theme,
                testimonial["name"] as String,
                testimonial["business"] as String,
                testimonial["rating"] as int,
                testimonial["testimonial"] as String,
                testimonial["avatar"] as String,
                testimonial["semanticLabel"] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds individual testimonial card
  Widget _buildTestimonialCard(
    ThemeData theme,
    String name,
    String business,
    int rating,
    String testimonial,
    String avatarUrl,
    String semanticLabel,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and info
          Row(
            children: [
              ClipOval(
                child: CustomImageWidget(
                  imageUrl: avatarUrl,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                  semanticLabel: semanticLabel,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      business,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Star Rating
              Row(
                children: List.generate(
                  rating,
                  (index) => Padding(
                    padding: EdgeInsets.only(left: index > 0 ? 0.5.w : 0),
                    child: CustomIconWidget(
                      iconName: 'star',
                      color: const Color(0xFFFF9500),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Testimonial Text
          Text(
            '"$testimonial"',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
