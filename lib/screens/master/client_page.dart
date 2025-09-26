import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'client_controller.dart';
import 'client_form.dart';


class ClientsPage extends StatelessWidget {
  final ClientController controller = Get.put(ClientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade200,
      appBar: AppBar(
        title: Text('Clients'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.dialog(ClientForm()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.clients.isEmpty) {
          return Center(child: Text('No clients found'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: controller.clients.length,
          itemBuilder: (context, index) {
            final c = controller.clients[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(c.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Phone: ${c.phone ?? '-'}'),
                            Text('Address: ${c.address ?? '-'}'),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.amber),
                            onPressed: () => Get.dialog(ClientForm(client: c)),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.amber),
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Delete Client',
                                middleText: 'Are you sure you want to delete ${c.name}?',
                                textCancel: 'Cancel',
                                textConfirm: 'Delete',
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  controller.deleteClient(c.id);
                                  Get.back();
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
