import 'package:flutter/material.dart';
import 'package:gestra/login.dart';
import 'package:gestra/privacyPolicy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';
import 'Theme/ThemeManager.dart';

class SettingsPage extends StatefulWidget {
  final void Function(int) onNavigate;
  const SettingsPage({super.key, required this.onNavigate});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = themeManager.themeMode == ThemeMode.dark;
    final Color activeColor = isDarkMode
        ? Colors.blueAccent
        : Colors.blue.shade800;
    final Color logoutBgColor = isDarkMode ? const Color(0xFF3F1D1D) : Colors.red.shade50;
    final Color logoutTextColor = isDarkMode ? Colors.redAccent : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        automaticallyImplyLeading: false,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        children: <Widget>[
          _buildSettingsHeader('UMUM', activeColor),
          _buildSettingsDivider(),

          SwitchListTile(
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('Ubah antara mode terang atau gelap.'),
            value: isDarkMode,
            activeThumbColor: activeColor,
            secondary: Icon(Icons.brightness_6, color: activeColor),
            onChanged: (bool value) {
              themeManager.toggleTheme(value);
              setState(() {});
            },
          ),

          // _buildSettingsDivider(),

          // _buildListTile(
          //   icon: Icons.language,

          //   title: 'Language',
          //   subtitle: 'English (US)',

          //   onTap: () {

          //   },
          // ),
          const SizedBox(height: 20),
          // _buildSettingsHeader('NOTIFICATIONS'),
          // _buildSettingsDivider(),

          // SwitchListTile(
          //   title: const Text(
          //     'Push Notifications',
          //     style: TextStyle(fontWeight: FontWeight.w500),
          //   ),
          //   subtitle: const Text('Receive alerts for new activity and updates.'),
          //   value: _notificationsEnabled,
          //   activeThumbColor: Color.fromRGBO(30, 64, 175, 1),
          //   onChanged: (bool value) {
          //     setState(() {
          //       _notificationsEnabled = value;
          //     });
          //   },
          //   secondary: Icon(
          //     Icons.notifications_active,
          //     color: Color.fromRGBO(30, 64, 175, 1),
          //   ),
          // ),

          // _buildSettingsDivider(),

          // const SizedBox(height: 20),
          _buildSettingsHeader('AKUN & BANTUAN', activeColor),
          _buildSettingsDivider(),

          _buildListTile(
            icon: Icons.person_outline,
            title: 'Kelola Akun',
            subtitle: 'Perbarui informasi akun Anda',
            color: activeColor,
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
            title: 'Kebijakan Privasi',
            color: activeColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
              );
            },
          ),

          _buildSettingsDivider(),

          _buildListTile(
            icon: Icons.info_outline,
            title: 'tentang GESTRA',
            subtitle: 'versi 1.0.0',
            color: activeColor,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Gestra',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Gestra Team',
                applicationIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.translate, color: activeColor, size: 40),
                ),
                children: const [
                  SizedBox(height: 20),
                  Text(
                    'Gestra adalah aplikasi penerjemah bahasa isyarat yang dirancang untuk memudahkan komunikasi inklusif.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoutBgColor,
                  foregroundColor: logoutTextColor,
                  elevation: 0,
                  side: BorderSide(color: logoutTextColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Keluar Akun",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('password');
              
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: color,
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
    required Color color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSettingsDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor,
      indent: 16,
      endIndent: 16,
    );
  }
}
