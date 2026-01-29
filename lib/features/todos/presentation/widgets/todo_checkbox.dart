import 'package:flutter/material.dart';
import 'package:todo_app/global/extensions/context_extension.dart';

class TodoCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;
  final double size;

  const TodoCheckbox({
    super.key,
    required this.isChecked,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isChecked
              ? context.colorScheme.primary
              : context.colorScheme.surface,
          border: Border.all(color: context.colorScheme.primary, width: 1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: isChecked
            ? Icon(
                Icons.check,
                color: context.colorScheme.onPrimary,
                size: size * 0.75,
              )
            : null,
      ),
    );
  }
}
