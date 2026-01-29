import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_app/global/theme/colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final VoidCallback? onBackPressed;
  final VoidCallback? onIconTap;
  final Widget? trailing;
  final double height;

  const AppHeader({
    super.key,
    required this.title,
    this.iconAsset,
    this.onBackPressed,
    this.onIconTap,
    this.trailing,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            left: -191,
            top: height > 150 ? 78 : -48,
            child: Container(
              width: 342,
              height: 342,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 44,
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Positioned(
            right: -82,
            top: -27,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 35,
                  color: AppColors.textOnPrimary.withOpacity(0.3),
                ),
              ),
            ),
          ),
          // Header content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: height > 150 ? 16 : 24,
              ),
              child: _buildHeaderContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (iconAsset != null)
          GestureDetector(
            onTap: onIconTap ?? onBackPressed ?? () => Navigator.pop(context),
            child: SvgPicture.asset(
              iconAsset!,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.textOnPrimary,
                BlendMode.srcIn,
              ),
            ),
          )
        else
          const SizedBox(width: 24),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        trailing ?? const SizedBox(width: 24),
      ],
    );
  }
}
