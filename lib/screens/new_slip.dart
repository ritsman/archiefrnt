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
                  SlipDetailsSection(controller: controller),
          
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Slip Number',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(text: controller.slipNumber.value),
              )),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Row 2: Client dropdown
        Obx(() => DropdownButtonFormField<Client>(
          decoration: const InputDecoration(
            labelText: 'Select Client',
            border: OutlineInputBorder(),
          ),
          items: controller.clients
              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
              .toList(),
          onChanged: (value) => controller.selectedClient.value = value,
          value: controller.selectedClient.value,
        )),

        const SizedBox(height: 12),

        // Row 3: Salesman dropdown
        Obx(() => DropdownButtonFormField<Salesman>(
          decoration: const InputDecoration(
            labelText: 'Select Salesman',
            border: OutlineInputBorder(),
          ),
          items: controller.salesmen
              .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
              .toList(),
          onChanged: (value) => controller.selectedSalesman.value = value,
          value: controller.selectedSalesman.value,
        )),

        const SizedBox(height: 12),

        // Row 4: Total weight, Vehicle number, and Transport charges
        Row(
          children: [
            // Total Weight



            // Vehicle Number with Autocomplete
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return controller.vehicleNumberSuggestions.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                  controller.vehicleNumberController = textController;
                  return TextFormField(
                    controller: controller.vehicleNumberController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
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
            const SizedBox(width: 16),

            // Transport Charges
            Expanded(
              child: Obx(() => TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Transport Charges',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final parsed = double.tryParse(val) ?? 0.0;
                  controller.transportCharges.value = parsed;
                },
                controller: TextEditingController(
                  text: controller.transportCharges.value == 0.0
                      ? ''
                      : controller.transportCharges.value.toStringAsFixed(2),
                ),
              )),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(() => TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Total Weight',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: controller.totalWeight.value.toStringAsFixed(2),
                ),
              )),
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
