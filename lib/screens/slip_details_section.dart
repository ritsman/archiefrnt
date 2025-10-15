import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'master/product.dart';
import 'slip_details.dart';
import 'new_slip_controller.dart';
import 'package:data_table_2/data_table_2.dart';

class SlipDetailsSection extends StatelessWidget {
  final NewSlipController controller;

  SlipDetailsSection({super.key, required this.controller});

  final _inputDecoration = const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    border: OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = controller.slipDetails;
      return Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
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
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 56,
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Rate')),
                      DataColumn(label: Text('Weight')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List.generate(details.length, (index) {
                      final detail = details[index];
                      return DataRow(
                        cells: [
                          DataCell(_buildProductDropdown(index, detail)),
                          DataCell(_buildTextField(
                            controller.quantityControllers,
                            index,
                            detail.quantity,
                                (val) => controller.onQuantityChanged(
                                index, double.tryParse(val) ?? 0),
                          )),
                          DataCell(_buildTextField(
                            controller.rateControllers,
                            index,
                            detail.rate,
                                (val) => controller.onRateChanged(
                                index, double.tryParse(val) ?? 0),
                          )),
                          DataCell(Text(
                            (detail.weight ?? 0).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 14),
                          )),
                          DataCell(Text(
                            (detail.amount ?? 0).toStringAsFixed(2),
                            style: const TextStyle(fontSize: 14),
                          )),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  controller.deleteSlipDetail(index),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: controller.addNewSlipDetail,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      );
    });
  }

  Widget _buildProductDropdown(int index, SlipDetail detail) {
    return DropdownButton<Product>(
      value: detail.product,
      hint: const Text('Select Product', style: TextStyle(fontSize: 14)),
      items: controller.products.map((Product product) {
        return DropdownMenuItem<Product>(
          value: product,
          child: Text(product.name, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (Product? selectedProduct) {
        if (selectedProduct != null) {
          controller.onProductSelected(index, selectedProduct);
        }
      },
    );
  }

  Widget _buildTextField(List<TextEditingController> controllers, int index,
      double? value, Function(String) onChanged) {
    if (index >= controllers.length) return const Text('—');
    final fieldController = controllers[index];

    return SizedBox(
      width: 100,
      child: TextField(
        controller: fieldController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14),
        onChanged: onChanged,
        decoration: _inputDecoration,
      ),
    );
  }
}
