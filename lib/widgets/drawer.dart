import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.business,
                    size: 35,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Business App',
                  style: AppTheme.drawerHeaderStyle,
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            Icons.home,
            'Home',
                () => Get.offAllNamed('/home'),
          ),
          _buildDrawerItem(
            Icons.local_shipping,
            'Dispatch',
                () => Get.toNamed('/dispatch'),
          ),
          _buildDrawerItem(
            Icons.bar_chart,
            'Reports',
                () => Get.toNamed('/reports'),
          ),
          _buildDrawerItem(
            Icons.note_add,
            'New Slip',
                () => Get.toNamed('/new-slip'),
          ),
          _buildDrawerItem(
            Icons.payment,
            'Payments',
                () => Get.toNamed('/payments'),
          ),_buildDrawerItem(
            Icons.payment,
            'Master',
                () => Get.toNamed('/master'),
          ),

        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Get.back(); // Close drawer
        onTap();
      },
    );
  }
}
