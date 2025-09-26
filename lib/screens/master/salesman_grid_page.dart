import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'salesman_controller.dart';
import 'salesman_form.dart';
import '../../../theme/app_theme.dart';

class SalesmanGridPage extends StatelessWidget {
  final SalesmanController controller = Get.put(SalesmanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade200,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Salesmen',style: AppTheme.headlineStyleLight,),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.add,color: Colors.white,),
            onPressed: () => Get.dialog(SalesmanForm()),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.salesmen.isEmpty) {
          return Center(child: Text('No salesmen found'));
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(8, 110, 8, 8),
          itemCount: controller.salesmen.length,
          itemBuilder: (context, index) {
            final s = controller.salesmen[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Optional: Add an avatar or leading icon here
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(s.name,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Commission: ${s.commission ?? '-'}'),
                            Text('Phone: ${s.phone ?? '-'}'),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.deepPurple),
                            onPressed: () =>
                                Get.dialog(SalesmanForm(salesman: s)),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.deepPurple),
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Delete Salesman',
                                middleText: 'Are you sure you want to delete ${s
                                    .name}?',
                                textCancel: 'Cancel',
                                textConfirm: 'Delete',
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  controller.deleteSalesman(s.id);
                                  Get.back();
                                },
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }}