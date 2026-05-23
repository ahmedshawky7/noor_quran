import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noor_quran/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:noor_quran/features/settings/presentation/cubit/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: state.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  context.read<SettingsCubit>().setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: Text(state.locale.languageCode == 'ar' ? 'العربية' : 'English'),
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
              const Divider(),
              const ListTile(
                title: Text('About'),
                subtitle: Text('Noor Quran v1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}