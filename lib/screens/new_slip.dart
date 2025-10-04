import 'package:container/screens/master/client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'new_slip_controller.dart';
import 'slip_details_section.dart'; // defined below
import 'master/salesman.dart';

class NewSlipPage extends StatelessWidget {
  final NewSlipController controller = Get.put(NewSlipController());

   NewSlipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:true,
      appBar: AppBar(title: Text('New Slip')),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          
                  // Section 1: Main Data Input
                  _buildMainDataSection(),
          
                  SizedBox(height: 12),
          
                  // Section 2: Slip Details Scrollable Table
                  SizedBox(height:300,child: SlipDetailsSection(controller: controller)),
          
                  SizedBox(height: 12),
          
                  // Section 3: Summary + Buttons
                  _buildSummarySection(),
                ],

          
          ),
        ),
      ),
    );
  }

  Widget _buildMainDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Date picker & Slip number (readonly)
        Row(
          children: [
            Expanded(
              child: Obx(() => InputDecorator(
                decoration: InputDecoration(labelText: 'Slip Date'),
                child: InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: Get.context!,
                      initialDate: controller.slipDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.updateSlipDate(picked);
                    }
                  },
                  child: Text(
                    '${controller.slipDate.value.toLocal().toIso8601String().substring(0, 10)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Obx(() => TextFormField(
                decoration: InputDecoration(
                  labelText: 'Slip Number',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(text: controller.slipNumber.value),
              )),
            ),
          ],
        ),

        SizedBox(height: 12),

        // Row 2: Client dropdown
        Obx(() => DropdownButtonFormField<Client>(
          decoration: InputDecoration(labelText: 'Select Client', border: OutlineInputBorder()),
          items: controller.clients.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
          onChanged: (value) => controller.selectedClient.value = value,
          value: controller.selectedClient.value,
        )),

        SizedBox(height: 12),

        // Row 3: Salesman dropdown
        Obx(() => DropdownButtonFormField<Salesman>(
          decoration: InputDecoration(labelText: 'Select Salesman', border: OutlineInputBorder()),
          items: controller.salesmen.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
          onChanged: (value) => controller.selectedSalesman.value = value,
          value: controller.selectedSalesman.value,
        )),

        SizedBox(height: 12),

        // Row 4: Calculated weight (readonly) and vehicle number input with suggestions
        Row(
          children: [
            Expanded(
              child: Obx(() => TextFormField(
                decoration: InputDecoration(
                  labelText: 'Total Weight',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(text: controller.totalWeight.value.toStringAsFixed(2)),
              )),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') return const Iterable<String>.empty();
                  return controller.vehicleNumberSuggestions.where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (context, controllerTextField, focusNode, onFieldSubmitted) {
                  controller.vehicleNumberController = controllerTextField;
                  return TextFormField(
                    controller: controller.vehicleNumberController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Number',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                onSelected: (selection) {
                  controller.vehicleNumberController.text = selection;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() => Text(
          "Total Quantity: ${controller.totalQuantity.value}    Total Amount: ${controller.totalAmount.value.toStringAsFixed(2)}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() => ElevatedButton(
              onPressed: controller.isSaving.value ? null : () => controller.saveSlip(print: true),
              child: Text('Save'),
            )),
            Obx(() => ElevatedButton(
              onPressed: controller.isSaving.value ? null : () => controller.saveSlip(print: true),
              child: Text('Save & Print'),
            )),
            ElevatedButton(
              onPressed: () => controller.findAndSelectPrinter(),
              child: Text('Select Printer'),
            ),
          ],
        ),
      ],
    );
  }
}
