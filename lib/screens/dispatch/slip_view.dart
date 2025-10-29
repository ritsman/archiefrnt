import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../slip.dart';




class SlipViewPage extends StatelessWidget {
  final Slip slip = Get.arguments as Slip;  // Pass Slip via navigation


  // Optionally, you can create a controller here if your UX requires editing capability:
  //final NewSlipController controller = Get.find<NewSlipController>();
  //Get.lazyPut(() =
  // ✅ Find or create controller safely
  // final NewSlipController controller = Get.put(
  //   NewSlipController(),
  //   //tag: slip.slipNumber, // optional tag to differentiate instances
  // );



  SlipViewPage({super.key}) {
    // Initialize controller's state from slip (for editing purposes)
    // controller.slipDate.value = slip.slipDate;
    // controller.slipNumber.value = slip.slipNumber;
    // controller.selectedClient.value = controller.clients.firstWhereOrNull((c) => c.id == slip.clientId);
    // controller.selectedSalesman.value = controller.salesmen.firstWhereOrNull((s) => s.id == slip.salesmanId);
    // controller.vehicleNumberController.text = slip.vehicleNumber ?? '';
    // controller.totalAmount.value = slip.totalAmount;
    // controller.slipDetails.assignAll(slip.slipDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slip: ${slip.slipNumber}'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _onPrint(),
            tooltip: 'Print Slip',
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _onEdit(),
            tooltip: 'Edit Slip',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            _buildBasicInfo(),
            SizedBox(height: 20),
            _buildSlipDetails(),
            SizedBox(height: 20),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date: ${slip.slipDate.toIso8601String().substring(0, 10)}', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text('Client ID: ${slip.client?.name}', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text('Salesman ID: ${slip.salesman?.name}', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text('Vehicle Number: ${slip.vehicleNumber ?? "N/A"}', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Text('Transport Charges: ${slip.transportCharges ?? "N/A"}', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildSlipDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Slip Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FractionColumnWidth(.3),
            1: FractionColumnWidth(.15),
            2: FractionColumnWidth(.15),
            3: FractionColumnWidth(.2),
            4: FractionColumnWidth(.2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade300),
              children: [
                Padding(padding: EdgeInsets.all(8), child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8), child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8), child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(8), child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            ...slip.slipDetails.map((detail) {
              print(detail);
              return TableRow(children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(detail.product?.name ?? 'Unknown'),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('${detail.quantity ?? "-"}'),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('${detail.rate?.toStringAsFixed(2) ?? "-"}'),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('${detail.weight?.toStringAsFixed(2) ?? "-"}'),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('${detail.amount?.toStringAsFixed(2) ?? "-"}'),
                ),
              ]);
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary() {
    double totalQty = slip.slipDetails.fold(0, (prev, d) => prev + (d.quantity ?? 0));
    double totalAmt = slip.slipDetails.fold(0, (prev, d) => prev + (d.amount ?? 0.0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('Total Quantity: $totalQty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text('Total Amount: ₹${totalAmt.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _onEdit() {
    print(slip.transportCharges);
    print("--------");
    print(slip);
    // Navigate to your existing NewSlipPage in edit mode, passing the slip
    // You may want to modify NewSlipController to support editing mode
    Get.toNamed('/new-slip', arguments: slip);


  }

  void _onPrint() {
    // TODO: Your print integration here
    Get.snackbar('Print', 'Printing slip #${slip.slipNumber}', snackPosition: SnackPosition.BOTTOM);
  }
}
