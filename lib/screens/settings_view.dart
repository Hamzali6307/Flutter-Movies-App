import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:test_app/l10n/app_localizations.dart';
import '../services/service_locator.dart';
import '../services/session_manager.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context);
    
    if (l10n == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String _getLanguageName(String code) {
      switch (code) {
        case 'en': return 'English';
        case 'hi': return 'Hindi (हिंदी)';
        case 'ur': return 'Urdu (اردو)';
        default: return code;
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        // User Profile Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.myProfile,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "Guest User",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),

        // Appearance Section
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            l10n.appearance,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
        SwitchListTile(
          secondary: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: themeProvider.isDarkMode ? Colors.amber : Colors.orange,
          ),
          title: Text(l10n.darkTheme),
          subtitle: Text(themeProvider.isDarkMode ? "Enabled" : "Disabled"),
          value: themeProvider.isDarkMode,
          activeColor: Colors.redAccent,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
        ),
        
        // Language Selection
        ListTile(
          leading: const Icon(Icons.language, color: Colors.blue),
          title: Text(l10n.language),
          subtitle: Text(_getLanguageName(languageProvider.locale.languageCode)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => _showLanguageDialog(context, languageProvider),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1),
        ),

        // General Section
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            l10n.general,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
        _buildSettingItem(context, Icons.privacy_tip_outlined, l10n.privacyPolicy, () {}),
        _buildSettingItem(context, Icons.info_outline, l10n.aboutUs, () {}),
        _buildSettingItem(context, Icons.help_outline, l10n.helpSupport, () {}),
        _buildSettingItem(context, Icons.verified_outlined, "${l10n.version} 1.0.0", null),
        const SizedBox(height: 20),
        _buildSettingItem(
          context,
          Icons.logout, 
          l10n.logout, 
          () => _showLogoutDialog(context, l10n), 
          isDestructive: true
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, provider, "English", 'en'),
            _buildLanguageOption(context, provider, "Hindi (हिंदी)", 'hi'),
            _buildLanguageOption(context, provider, "Urdu (اردو)", 'ur'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, LanguageProvider provider, String title, String code) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: code,
        groupValue: provider.locale.languageCode,
        onChanged: (value) {
          if (value != null) {
            provider.setLanguage(value);
          }
          Navigator.pop(context);
        },
      ),
      onTap: () {
        provider.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await getIt<SessionManager>().endSession(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.logout, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, VoidCallback? onTap, {bool isDestructive = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isDestructive ? Colors.redAccent : Theme.of(context).iconTheme.color),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16, 
              color: isDestructive ? Colors.redAccent : null,
              fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14) : null,
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}
