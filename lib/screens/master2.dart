import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/drawer.dart';
import 'master/new_client.dart';
//import master pages
import 'master/salesman_grid_page.dart';

class MasterScreen extends StatelessWidget {
  final List<_CardItem> items = [
    _CardItem('New Client', Icons.add_circle_outline, AddNewClient()),
    _CardItem('Add on', Icons.add_circle_outline, AddOnPage()),
    _CardItem('Bills & statement', Icons.receipt_long, BillsStatementPage()),
    _CardItem('Payment history', Icons.history, PaymentHistoryPage()),
    _CardItem('Invoice history', Icons.description, InvoiceHistoryPage()),
    _CardItem('Salesman', Icons.people_alt, SalesmanGridPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payments & history')),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: items.map((item) {
                return GestureDetector(
                  onTap: () => Get.to(() => item.page),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[50],
                        child: Icon(item.icon, color: Colors.blue, size: 28),
                        radius: 28,
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardItem {
  final String title;
  final IconData icon;
  final Widget page;
  _CardItem(this.title, this.icon, this.page);
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