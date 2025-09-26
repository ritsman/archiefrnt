import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/drawer.dart';

//import master pages

import '../widgets/card.dart';

class MasterScreen extends StatelessWidget {


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
        title: Text(
          'Master',
          style: AppTheme.headlineStyleLight,
        ),
      ),
      drawer: AppDrawer(),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(

              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                NavCard(title: 'Clients', icon: Icons.quick_contacts_mail, color: AppColors.dispatch, onTap: () => Get.toNamed('/master/clients')),
                NavCard(title: 'Salesman', icon: Icons.category, color: AppColors.dispatch, onTap: () => Get.toNamed('/master/salesman')),
                NavCard(title: 'Products', icon: Icons.production_quantity_limits, color: AppColors.dispatch, onTap: () => Get.toNamed('/master/products')),
                Text('master children2'),
              ]),
          ]),
        ),
      ),
    );
  }
}



class PayBillPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Pay Bill')),
        body: Center(child: Text('Pay Bill Page')),
      );
}

class AddOnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Add On')),
        body: Center(child: Text('Add On Page')),
      );
}

class BillsStatementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Bills & Statement')),
        body: Center(child: Text('Bills & Statement Page')),
      );
}

class PaymentHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Payment History')),
        body: Center(child: Text('Payment History Page')),
      );
}

class InvoiceHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Invoice History')),
        body: Center(child: Text('Invoice History Page')),
      );
}

class SalesmanSamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Invoice History')),
        body: Center(child: Text('Invoice History Page')),
      );
}
