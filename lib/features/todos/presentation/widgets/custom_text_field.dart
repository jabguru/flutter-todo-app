import 'package:flutter/material.dart';
import 'package:todo_app/global/extensions/context_extension.dart';
import 'package:todo_app/global/widgets/space.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final int? maxLines;
  final bool expands;
  final double? height;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.maxLines = 1,
    this.expands = false,
    this.height,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelMedium),
        const VerticalSpacing(8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            border: Border.all(color: context.colorScheme.outline),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            expands: expands,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            textAlignVertical: expands ? TextAlignVertical.top : null,
            style: context.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: const TextStyle(height: 0.5),
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixIconTap,
                      child: Icon(
                        suffixIcon,
                        color: context.colorScheme.onSurface,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
