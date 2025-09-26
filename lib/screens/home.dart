import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../widgets/drawer.dart';
import '../widgets/card.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.red),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        // Important for Material3
        shadowColor: Colors.transparent,
        title: Text('Business App', style: AppTheme.headlineStyleLight,),

      ),
      drawer: AppDrawer(),
      body: Container(

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(

            children: [
              Center(
                child: Text(
                  'Dashboard',
                  style: AppTheme.headlineStyleLight,
                ),
              ),
              SizedBox(height: 60),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  NavCard(title: 'Dispatch', icon: Icons.local_shipping, color: AppColors.dispatch, onTap: () => Get.toNamed('/dispatch')),
                  NavCard(title: 'Reports', icon: Icons.bar_chart, color: AppColors.reports, onTap: () => Get.toNamed('/reports')),
                  NavCard(title: 'New Slip', icon: Icons.note_add, color: AppColors.newSlip, onTap: () => Get.toNamed('/new-slip')),
                  NavCard(title: 'Payments', icon: Icons.payment, color: AppColors.payments, onTap: () => Get.toNamed('/payments'))
,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}