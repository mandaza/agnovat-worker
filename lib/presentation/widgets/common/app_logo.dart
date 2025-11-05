import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';

/// App logo widget that displays the Agnovat logo
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: _buildLogoContent(),
      ),
    );
  }

  Widget _buildLogoContent() {
    // Try to load the logo image from assets
    // If it doesn't exist, fall back to icon
    return Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to icon if image not found
        return Icon(
          Icons.support_agent,
          size: size * 0.5,
          color: Colors.white,
        );
      },
    );
  }
}
