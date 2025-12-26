import 'package:flutter/material.dart';
import 'profile.dart';

final Color primaryBlue = Colors.blue.shade800;

class SettingsPage extends StatefulWidget {
  final void Function(int) onNavigate;
  const SettingsPage({super.key, required this.onNavigate});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        children: <Widget>[
          _buildSettingsHeader('GENERAL'),
          _buildSettingsDivider(),

          SwitchListTile(
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Switch between light and dark themes.'),
            value: _isDarkMode,
            activeThumbColor: Color.fromRGBO(30, 64, 175, 1),
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
            },
            secondary: Icon(
              Icons.brightness_6,
              color: Color.fromRGBO(30, 64, 175, 1),
            ),
          ),

          _buildSettingsDivider(),

          _buildListTile(
            icon: Icons.language,
<<<<<<< Updated upstream
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () {
              
            },
=======
            title: 'Bahasa',
            subtitle: 'Indonesia',
            onTap: () {},
>>>>>>> Stashed changes
          ),

          const SizedBox(height: 20),
          _buildSettingsHeader('NOTIFICATIONS'),
          _buildSettingsDivider(),

          SwitchListTile(
            title: const Text(
              'Push Notifications',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Receive alerts for new activity and updates.'),
            value: _notificationsEnabled,
            activeThumbColor: Color.fromRGBO(30, 64, 175, 1),
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: Icon(
              Icons.notifications_active,
              color: Color.fromRGBO(30, 64, 175, 1),
            ),
          ),

          _buildSettingsDivider(),

          const SizedBox(height: 20),
          _buildSettingsHeader('ACCOUNT & SUPPORT'),
          _buildSettingsDivider(),

          _buildListTile(
            icon: Icons.person_outline,
            title: 'Manage Account',
            subtitle: 'Update your profile and security settings.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),

          _buildSettingsDivider(),

          _buildListTile(
            icon: Icons.lock_outline,
<<<<<<< Updated upstream
            title: 'Privacy Policy',
            onTap: () {

            },
=======
            title: 'Kebijakan Privasi',
            onTap: () {},
>>>>>>> Stashed changes
          ),

          _buildSettingsDivider(),

          _buildListTile(
            icon: Icons.info_outline,
<<<<<<< Updated upstream
            title: 'About GESTRA',
            subtitle: 'Version 1.0.0',
            onTap: () {

            },
=======
            title: 'tentang GESTRA',
            subtitle: 'versi 1.0.0',
            onTap: () {},
>>>>>>> Stashed changes
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Color.fromRGBO(30, 64, 175, 1),
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color.fromRGBO(30, 64, 175, 1)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }

  Widget _buildSettingsDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 16,
      endIndent: 16,
    );
  }
}
