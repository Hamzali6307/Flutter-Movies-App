import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/service_locator.dart';
import '../services/session_manager.dart';
import '../providers/theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                  color: Colors.redAccent.withOpacity(0.2),
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
                  const Text(
                    "My Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            "Appearance",
            style: TextStyle(
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
          title: const Text("Dark Theme"),
          subtitle: Text(themeProvider.isDarkMode ? "Dark Mode Enabled" : "Light Mode Enabled"),
          value: themeProvider.isDarkMode,
          activeColor: Colors.redAccent,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1),
        ),

        // General Section
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            "General",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
        _buildSettingItem(context, Icons.privacy_tip_outlined, "Privacy Policy", () {}),
        _buildSettingItem(context, Icons.info_outline, "About Us", () {}),
        _buildSettingItem(context, Icons.help_outline, "Help & Support", () {}),
        _buildSettingItem(context, Icons.verified_outlined, "Version 1.0.0", null),
        const SizedBox(height: 20),
        _buildSettingItem(
          context,
          Icons.logout, 
          "Logout", 
          () => _showLogoutDialog(context), 
          isDestructive: true
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await getIt<SessionManager>().endSession(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
