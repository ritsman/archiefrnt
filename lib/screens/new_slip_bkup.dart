import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/drawer.dart';
class NewSlipScreen extends StatelessWidget {
  const NewSlipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Slip'),
        backgroundColor: AppColors.newSlip,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add,
              size: 80,
              color: AppColors.newSlip,
            ),
            SizedBox(height: 20),
            Text(
              'Hello World - New Slip Screen',
              style: AppTheme.screenTitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
