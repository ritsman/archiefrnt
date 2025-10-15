
import 'package:container/screens/dispatch/dispatch_screen.dart';
import 'package:container/screens/master/client_page.dart';

import 'package:container/screens/master/product_page.dart';
import 'package:container/screens/payments/payments_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'widgets/drawer.dart';
//screen imports-----------
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/new_slip.dart';
import 'screens/master.dart';
import 'screens/master/salesman_grid_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Business App',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/dispatch', page: () => DispatchScreen()),
        GetPage(name: '/reports', page: () => ReportsScreen()),
        GetPage(name: '/new-slip', page: () => NewSlipPage()),
        GetPage(name: '/payments', page: () => PaymentsScreen()),
        GetPage(name: '/master', page: () => MasterScreen()),
        GetPage(name: '/master/salesman', page: () => SalesmanGridPage()),
        GetPage(name: '/master/clients', page: () => ClientsPage()),
        GetPage(name: '/master/products', page: () => ProductsPage()),

      ],
    );
  }
}







class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        backgroundColor: AppColors.reports,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 80,
              color: AppColors.reports,
            ),
            SizedBox(height: 20),
            Text(
              'Hello World - Reports Screen',
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

//
// class PaymentsScreen extends StatelessWidget {
//   const PaymentsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Payments'),
//         backgroundColor: AppColors.payments,
//         foregroundColor: Colors.white,
//       ),
//       drawer: AppDrawer(),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.payment,
//               size: 80,
//               color: AppColors.payments,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Hello World - Payments Screen',
//               style: AppTheme.screenTitleStyle,
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Get.back(),
//               child: Text('Go Back'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//


