import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'master/product.dart';
import 'slip_details.dart';
import 'new_slip_controller.dart';
import 'package:data_table_2/data_table_2.dart';


class SlipDetailsSection extends StatelessWidget {
  final NewSlipController controller;

  SlipDetailsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = controller.slipDetails;
      return Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height*0.6
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: 700,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    columns: [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Rate')),
                      DataColumn(label: Text('Weight')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List.generate(details.length, (index) {
                      final detail = details[index];
                      return DataRow(cells: [
                        DataCell(_buildProductDropdown(index, detail)),
                        DataCell(_buildQuantityField(index, detail)),
                        DataCell(Padding(padding:const EdgeInsets.symmetric(vertical: 6.0),child:_buildRateField(index, detail))),
                        DataCell(Text((detail.weight ?? 0).toStringAsFixed(2))),
                        DataCell(Text((detail.amount ?? 0).toStringAsFixed(2))),
                        DataCell(IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteSlipDetail(index),
                        )),
                      ]);
                    }),
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: controller.addNewSlipDetail,
            icon: Icon(Icons.add),
            label: Text('Add Item'),
          ),
        ],
      );
    });
  }

  Widget _buildProductDropdown(int index, SlipDetail detail) {
    return DropdownButton<Product>(
      value: detail.product,
      hint: Text('Select Product'),
      items: controller.products.map((Product product) {
        return DropdownMenuItem<Product>(
          value: product,
          child: Text(product.name,style: const TextStyle(fontSize: 14),),
        );
      }).toList(),
      onChanged: (Product? selectedProduct) {
        if (selectedProduct != null) {
          controller.onProductSelected(index, selectedProduct);
        }
      },
    );
  }

  Widget _buildQuantityField(int index, SlipDetail detail) {
    if (index >= controller.quantityControllers.length) {
      return Text('hello'); // or a loading placeholder
    }
    //final qtyController = TextEditingController(text: detail.quantity?.toString() ?? '');
    final qtyController = controller.quantityControllers[index];
    return SizedBox(
      width: 90,
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textAlignVertical: TextAlignVertical.center, // centers text vertically
        style: const TextStyle(fontSize: 14), // ensure same font
        controller: qtyController,
        onChanged: (val) {
          double qty = double.tryParse(val) ?? 0;
          controller.onQuantityChanged(index, qty);
        },
        decoration: InputDecoration(border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),),
      ),
    );
  }

  Widget _buildRateField(int index, SlipDetail detail) {
    if (index >= controller.rateControllers.length) {
      return Text('hello'); // or a loading placeholder
    }
    //final rateController = TextEditingController(text: detail.rate?.toString() ?? '');
    final rateController = controller.rateControllers[index];
    return SizedBox(
      width: 110,

      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textAlignVertical: TextAlignVertical.center, // centers text vertically
        style: const TextStyle(fontSize: 14), // ensure same font
        controller: rateController,
        onChanged: (val) {
          double rate = double.tryParse(val) ?? 0.0;
          controller.onRateChanged(index, rate);
        },
        decoration: InputDecoration(border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),),
      ),
    );
  }
}
