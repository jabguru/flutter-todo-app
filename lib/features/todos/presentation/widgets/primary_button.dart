import 'package:flutter/material.dart';
import 'package:todo_app/global/extensions/context_extension.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 358,
    this.height = 56,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDisabled
            ? context.colorScheme.primary.withValues(alpha: 0.5)
            : context.colorScheme.primary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(text, style: context.textTheme.labelLarge),
          ),
        ),
      ),
    );
  }
}
