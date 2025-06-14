import 'package:flutter/material.dart';
import 'package:gradproject/core/cahce/share_prefs.dart';
import 'package:gradproject/core/utils/config/routes.dart';
import 'package:gradproject/core/utils/styles/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Logout Confirmation",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            // "Cancel" button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),

            FilledButton(
              onPressed: () async {
                // ✅ Remove tokens from cache
                await CacheHelper.removeData('token');
                await CacheHelper.removeData('refreshToken');

                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.login,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Logout"),
            ),
          ],
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
          onPressed: () => _showLogoutDialog(context),
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
