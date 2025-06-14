import 'package:flutter/material.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/styles/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLogoutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              const Center(
                child: Text(
                  "Are you sure you want to logout?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // ✅ Remove tokens from cache
                  await CacheHelper.removeData('token');
                  await CacheHelper.removeData('refreshToken');

                  // ✅ Navigate to login screen
                  Navigator.of(context).pop(); // Close the modal
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.login, (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text("Logout"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close modal
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.teal,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showLogoutModal(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
