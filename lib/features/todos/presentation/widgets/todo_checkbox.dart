import 'package:flutter/material.dart';
import 'package:todo_app/global/theme/colors.dart';

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
          color: isChecked ? AppColors.primary : AppColors.surface,
          border: Border.all(color: AppColors.primary, width: 1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: isChecked
            ? Icon(Icons.check, color: AppColors.white, size: size * 0.75)
            : null,
      ),
    );
  }
}
