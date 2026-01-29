import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:todo_app/features/settings/presentation/cubit/theme_state.dart';
import 'package:todo_app/global/extensions/context_extension.dart';

/// Widget to display theme selection dialog
class ThemeDialog extends StatelessWidget {
  const ThemeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ThemeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return AlertDialog(
          title: const Text(
            'Choose Theme',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOption(
                title: 'Light',
                icon: Icons.light_mode,
                themeMode: ThemeMode.light,
                isSelected: state.themeMode == ThemeMode.light,
                onTap: () {
                  context.read<ThemeCubit>().changeThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              _ThemeOption(
                title: 'Dark',
                icon: Icons.dark_mode,
                themeMode: ThemeMode.dark,
                isSelected: state.themeMode == ThemeMode.dark,
                onTap: () {
                  context.read<ThemeCubit>().changeThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              _ThemeOption(
                title: 'System',
                icon: Icons.brightness_auto,
                themeMode: ThemeMode.system,
                isSelected: state.themeMode == ThemeMode.system,
                onTap: () {
                  context.read<ThemeCubit>().changeThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.themeMode,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final ThemeMode themeMode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? context.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? context.colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: context.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
