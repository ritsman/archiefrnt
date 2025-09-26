import 'package:container/screens/dispatch/slip_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dispatch_controller.dart';
import '../slip.dart';

class DispatchScreen extends StatelessWidget {
  final DispatchController controller = Get.put(DispatchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dispatch (All Slips)')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.slips.isEmpty) {
          return Center(child: Text('No slips found.'));
        }
        return ListView.separated(
          padding: EdgeInsets.all(12),
          itemCount: controller.slips.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) {
            final slip = controller.slips[index];
            //print(slip);
            return Card(
              child: ListTile(
                title: Text("Slip: ${slip.slipNumber}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: ${slip.slipDate.toIso8601String().substring(0,10)}"),
                    Text("Client ID: ${slip.client?.name} | Salesman ID: ${slip.salesman?.name}"),
                    Text("Amount: ₹${slip.totalAmount.toStringAsFixed(2)}"),
                    if (slip.vehicleNumber != null && slip.vehicleNumber!.isNotEmpty)
                      Text("Vehicle: ${slip.vehicleNumber}"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () => Get.to(()=>SlipViewPage(),arguments: slip),
                      tooltip: "View",
                    ),
                    IconButton(
                      icon: Icon(Icons.print, color: Colors.green),
                      onPressed: () => controller.printSlip(slip),
                      tooltip: "Print",
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Delete Slip",
                          middleText: "Delete slip ${slip.slipNumber}?",
                          textConfirm: "Delete",
                          confirmTextColor: Colors.white,
                          textCancel: "Cancel",
                          onConfirm: () {
                            controller.deleteSlip(slip.id);
                            Get.back();
                          },
                        );
                      },
                      tooltip: "Delete",
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
