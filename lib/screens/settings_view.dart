import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/service_locator.dart';
import '../services/session_manager.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "Guest User",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: Colors.white12),
        ),
        _buildSettingItem(Icons.privacy_tip_outlined, "Privacy Policy", () {}),
        _buildSettingItem(Icons.info_outline, "About Us", () {}),
        _buildSettingItem(Icons.help_outline, "Help & Support", () {}),
        _buildSettingItem(Icons.verified_outlined, "Version 1.0.0", null),
        const SizedBox(height: 20),
        _buildSettingItem(
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
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to logout?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Use SessionManager to end the session and navigate to login
              await getIt<SessionManager>().endSession(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback? onTap, {bool isDestructive = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16, 
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24) : null,
          onTap: onTap,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: Colors.white10, height: 1),
        ),
      ],
    );
  }
}
