import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/global/extensions/context_extension.dart';
import 'package:todo_app/global/widgets/space.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool canPop;

  const AppHeader({
    super.key,
    required this.title,
    this.canPop = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 222.0,
      decoration: BoxDecoration(color: context.colorScheme.primary),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            left: -191,
            top: 78,
            child: Container(
              width: 342,
              height: 342,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 44,
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.2),
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
                  color: context.colorScheme.onPrimary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          // Header content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
              child: _buildHeaderContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (canPop)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: context.colorScheme.onPrimary,
                  radius: 24.0,
                  child: Icon(
                    Icons.close,
                    color: context.colorScheme.primary,
                    size: 24.0,
                  ),
                ),
              )
            else
              const HorizontalSpacing(48.0),
            Expanded(
              child: Text(
                DateFormat("MMMM dd, yyyy").format(DateTime.now()),
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            trailing ?? const HorizontalSpacing(48.0),
          ],
        ),
        VerticalSpacing(24.0),
        Text(
          title,
          style: context.textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
