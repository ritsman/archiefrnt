import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_controller.dart';
import 'product_form.dart';


class ProductsPage extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime.shade200,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.lime,
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add,color: Colors.white,),
            onPressed: () => Get.dialog(ProductForm()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.products.isEmpty) {
          return Center(child: Text('No products found'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final p = controller.products[index];
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
                            Text(p.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Weight: ${p.weight ?? '-'}'),
                            Text('Rate: ${p.rate ?? '-'}'),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.lime),
                            onPressed: () => Get.dialog(ProductForm(product: p)),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.lime),
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Delete Product',
                                middleText: 'Are you sure you want to delete ${p.name}?',
                                textCancel: 'Cancel',
                                textConfirm: 'Delete',
                                confirmTextColor: Colors.white,
                                onConfirm: () {
                                  controller.deleteProduct(p.id);
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
  }
}
