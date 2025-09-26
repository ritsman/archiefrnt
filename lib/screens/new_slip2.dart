import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'dart:async';

// Model for Party/Client
class Party {
  final String name;
  final String mobile;

  Party({required this.name, required this.mobile});
}

// Model for Grid Row
class GridRow {
  final String product;
  final RxDouble quantity;
  final RxDouble weight;
  final RxDouble rate;
  final RxDouble amount;
  final bool isEditable;

  GridRow({
    required this.product,
    double quantity = 0.0,
    double weight = 0.0,
    double rate = 0.0,
    this.isEditable = false,
  }) : quantity = quantity.obs,
        weight = weight.obs,
        rate = rate.obs,
        amount = 0.0.obs;

  void calculateAmount() {
    amount.value = rate.value * weight.value;
  }
}

// Printer Model
class NetworkPrinter {
  final String ip;
  final int port;
  final String name;

  NetworkPrinter({required this.ip, this.port = 9100, required this.name});
}

// Controller
class SlipFormController extends GetxController {
  // Date and slip number
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString slipNumber = 'SL001'.obs;

  // Party/Client selection
  final Rx<Party?> selectedParty = Rx<Party?>(null);
  final RxList<Party> parties = <Party>[].obs;

  // Transport details
  final RxDouble totalWeight = 0.0.obs;
  final RxString transportVehicle = ''.obs;

  // Grid rows
  final RxList<GridRow> gridRows = <GridRow>[].obs;

  // Signature controllers
  final recipientSignatureController = TextEditingController();
  final senderSignatureController = TextEditingController();

  // Printer related
  final RxList<NetworkPrinter> discoveredPrinters = <NetworkPrinter>[].obs;
  final RxBool isDiscovering = false.obs;
  final RxBool isPrinting = false.obs;
  final RxString printStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  void initializeData() {
    // Initialize parties (mock data - replace with API call)
    parties.addAll([
      Party(name: 'John Doe', mobile: '+91 9876543210'),
      Party(name: 'Jane Smith', mobile: '+91 9876543211'),
      Party(name: 'Bob Johnson', mobile: '+91 9876543212'),
      Party(name: 'Alice Brown', mobile: '+91 9876543213'),
    ]);

    // Initialize grid rows
    gridRows.addAll([
      GridRow(product: '50 KG Pack'),
      GridRow(product: '30 KG Pack'),
      GridRow(product: '10 KG Pack *3P'),
      GridRow(product: '10 KG Pack *3L'),
      GridRow(product: '5 KG Pack *6'),
      GridRow(product: 'Packing Charges'),
    ]);

    // Listen to changes in grid rows to calculate total weight
    ever(gridRows, (_) => calculateTotalWeight());
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectParty(Party party) {
    selectedParty.value = party;
  }

  void updateTransportVehicle(String vehicle) {
    transportVehicle.value = vehicle;
  }

  void addBlankRow() {
    gridRows.insert(gridRows.length - 1, GridRow(product: '', isEditable: true));
  }

  void updateGridRow(int index, {double? quantity, double? weight, double? rate, String? product}) {
    final row = gridRows[index];
    if (quantity != null) row.quantity.value = quantity;
    if (weight != null) row.weight.value = weight;
    if (rate != null) row.rate.value = rate;
    if (product != null && row.isEditable) {
      // For editable rows, we need to replace the row
      gridRows[index] = GridRow(
        product: product,
        quantity: row.quantity.value,
        weight: row.weight.value,
        rate: row.rate.value,
        isEditable: true,
      );
    }
    row.calculateAmount();
    calculateTotalWeight();
  }

  void calculateTotalWeight() {
    double total = 0.0;
    for (var row in gridRows) {
      total += row.weight.value;
    }
    totalWeight.value = total;
  }

  // Save and Print Functions
  void saveSlip() {
    // Validate form
    if (selectedParty.value == null) {
      Get.snackbar('Error', 'Please select a party/client');
      return;
    }

    if (transportVehicle.value.isEmpty) {
      Get.snackbar('Error', 'Please enter transport vehicle');
      return;
    }

    // Save logic here (database, shared preferences, etc.)
    Get.snackbar('Success', 'Slip saved successfully!');
  }

  Future<void> discoverPrinters() async {
    isDiscovering.value = true;
    printStatus.value = 'Discovering printers...';
    discoveredPrinters.clear();

    try {
      // Get current network info
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();

      if (wifiIP == null) {
        printStatus.value = 'Not connected to WiFi';
        isDiscovering.value = false;
        return;
      }

      // Extract network subnet
      final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));

      // Common printer ports
      final List<int> printerPorts = [9100, 515, 631, 9101, 9102];

      // Create a list of futures for parallel scanning
      List<Future<void>> scanTasks = [];

      for (int i = 1; i <= 254; i++) {
        final host = '$subnet.$i';

        // Create a task for each host
        scanTasks.add(_scanHost(host, printerPorts));
      }

      // Wait for all scans to complete with timeout
      await Future.wait(scanTasks).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          printStatus.value = 'Scan timeout - Found ${discoveredPrinters.length} printer(s)';
          return <void>[];
        },
      );

      if (discoveredPrinters.isEmpty) {
        printStatus.value = 'No printers found on network';
      } else {
        printStatus.value = 'Found ${discoveredPrinters.length} printer(s)';
      }
    } catch (e) {
      printStatus.value = 'Error discovering printers: $e';
    } finally {
      isDiscovering.value = false;
    }
  }

  Future<void> _scanHost(String host, List<int> ports) async {
    for (int port in ports) {
      try {
        final socket = await Socket.connect(
            host,
            port,
            timeout: const Duration(milliseconds: 500)
        );
        socket.destroy();

        // Found a potential printer
        discoveredPrinters.add(NetworkPrinter(
          ip: host,
          port: port,
          name: 'Printer at $host:$port',
        ));

        // Break after finding first open port on this host
        break;
      } catch (e) {
        // Host/port not reachable, continue to next port
      }
    }
  }

  Future<void> printSlip([NetworkPrinter? printer]) async {
    if (selectedParty.value == null) {
      Get.snackbar('Error', 'Please select a party/client before printing');
      return;
    }

    isPrinting.value = true;
    printStatus.value = 'Printing...';

    try {
      NetworkPrinter? selectedPrinter = printer;

      if (selectedPrinter == null) {
        if (discoveredPrinters.isEmpty) {
          await discoverPrinters();
        }

        if (discoveredPrinters.isNotEmpty) {
          selectedPrinter = discoveredPrinters.first;
        } else {
          printStatus.value = 'No printers available';
          isPrinting.value = false;
          return;
        }
      }

      // Generate print data
      final printData = await _generatePrintData();

      // Send to printer
      await _sendToPrinter(selectedPrinter, printData);

      printStatus.value = 'Printed successfully!';
      Get.snackbar('Success', 'Slip printed successfully!');

    } catch (e) {
      printStatus.value = 'Print error: $e';
      Get.snackbar('Error', 'Failed to print: $e');
    } finally {
      isPrinting.value = false;
    }
  }

  Future<Uint8List> _generatePrintData() async {
    // Create ESC/POS commands for thermal printer
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text('DELIVERY SLIP',
        styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2));
    bytes += generator.text('================================',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.emptyLines(1);

    // Date and Slip Number
    bytes += generator.row([
      PosColumn(text: 'Date:', width: 3),
      PosColumn(text: DateFormat('dd/MM/yyyy').format(selectedDate.value), width: 5),
      PosColumn(text: 'Slip#:', width: 2),
      PosColumn(text: slipNumber.value, width: 2),
    ]);

    // Party Details
    if (selectedParty.value != null) {
      bytes += generator.emptyLines(1);
      bytes += generator.text('Party: ${selectedParty.value!.name}',
          styles: const PosStyles(bold: true));
      bytes += generator.text('Mobile: ${selectedParty.value!.mobile}');
    }

    // Transport Details
    bytes += generator.emptyLines(1);
    bytes += generator.text('Transport: ${transportVehicle.value}');
    bytes += generator.text('Total Weight: ${totalWeight.value.toStringAsFixed(1)} KG');

    // Grid Header
    bytes += generator.emptyLines(1);
    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(text: 'Product', width: 4),
      PosColumn(text: 'Qty', width: 2),
      PosColumn(text: 'Wt', width: 2),
      PosColumn(text: 'Rate', width: 2),
      PosColumn(text: 'Amt', width: 2),
    ]);
    bytes += generator.text('================================');

    // Grid Rows
    double totalAmount = 0.0;
    for (var row in gridRows) {
      if (row.quantity.value > 0 || row.weight.value > 0 || row.rate.value > 0) {
        bytes += generator.row([
          PosColumn(text: row.product.length > 12 ? row.product.substring(0, 12) : row.product, width: 4),
          PosColumn(text: row.quantity.value.toStringAsFixed(0), width: 2),
          PosColumn(text: row.weight.value.toStringAsFixed(1), width: 2),
          PosColumn(text: row.rate.value.toStringAsFixed(0), width: 2),
          PosColumn(text: row.amount.value.toStringAsFixed(0), width: 2),
        ]);
        totalAmount += row.amount.value;
      }
    }

    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(text: 'TOTAL:', width: 8, styles: const PosStyles(bold: true)),
      PosColumn(text: totalAmount.toStringAsFixed(2), width: 4, styles: const PosStyles(bold: true)),
    ]);

    // Signatures
    bytes += generator.emptyLines(2);
    bytes += generator.row([
      PosColumn(text: 'Recipient Sign:', width: 6),
      PosColumn(text: 'Sender Sign:', width: 6),
    ]);
    bytes += generator.emptyLines(3);

    // Footer
    bytes += generator.text('Thank you for your business!',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.emptyLines(2);
    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }

  Future<void> _sendToPrinter(NetworkPrinter printer, Uint8List data) async {
    Socket? socket;
    try {
      socket = await Socket.connect(printer.ip, printer.port, timeout: const Duration(seconds: 5));
      socket.add(data);
      await socket.flush();
      await Future.delayed(const Duration(seconds: 2)); // Wait for printing
    } finally {
      socket?.destroy();
    }
  }

  @override
  void onClose() {
    recipientSignatureController.dispose();
    senderSignatureController.dispose();
    super.onClose();
  }
}

// Main Form Widget
class SlipForm extends StatelessWidget {
  final SlipFormController controller = Get.put(SlipFormController());

  SlipForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slip Form'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: Date and Slip Number
            _buildDateAndSlipRow(),
            const SizedBox(height: 16),

            // Second Row: Party/Client Dropdown
            _buildPartyDropdown(),
            const SizedBox(height: 16),

            // Third Row: Total Weight and Transport Vehicle
            _buildTotalWeightAndTransport(),
            const SizedBox(height: 16),

            // Grid
            _buildGrid(),
            const SizedBox(height: 16),

            // Add Row Button
            _buildAddRowButton(),
            const SizedBox(height: 24),

            // Signature Section
            _buildSignatureSection(),
            const SizedBox(height: 24),

            // Save and Print Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndSlipRow() {
    return Row(
      children: [
        // Date Selector
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                    '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                    style: const TextStyle(fontSize: 16),
                  )),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Slip Number Display
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Row(
              children: [
                const Text('Slip #: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() => Text(controller.slipNumber.value)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Party/Client:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<Party>(
          key: ValueKey(controller.selectedParty.value?? 'no_selection'), // Unique key
          menuMaxHeight: 600,
          isExpanded:true,
          value: null,
          decoration: InputDecoration(

            hintText: 'Select Party/Client',
            //border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: controller.parties.map((party) => DropdownMenuItem(
            value: party,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(party.mobile, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ).toList(),
          onChanged: (party) {
            if (party != null) {
              controller.selectParty(party);
            }
          },
        )),
        const SizedBox(height: 8),
        Obx(() => controller.selectedParty.value != null
            ?
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.selectedParty.value!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      controller.selectedParty.value!.mobile,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

        )
            : const SizedBox()),
      ],
    );
  }

  Widget _buildTotalWeightAndTransport() {
    return Row(
      children: [
        // Total Weight
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Row(
              children: [
                const Text('Total Weight: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Obx(() => Text('${controller.totalWeight.value.toStringAsFixed(1)} KG')),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Transport Vehicle
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Transport Vehicle',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) => controller.updateTransportVehicle(value),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Column(
      children: [
        // Grid Header
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),

        // Grid Rows
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: List.generate(
              controller.gridRows.length,
                  (index) => _buildGridRow(index),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildGridRow(int index) {
    final row = controller.gridRows[index];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          // Product
          Expanded(
            flex: 3,
            child: row.isEditable
                ? TextFormField(
              initialValue: row.product,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onChanged: (value) => controller.updateGridRow(index, product: value),
            )
                : Text(row.product),
          ),
          // Quantity
          Expanded(
            flex: 2,
            child: Obx(() => TextFormField(
              initialValue: row.quantity.value == 0 ? '' : row.quantity.value.toString(),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final quantity = double.tryParse(value) ?? 0.0;
                controller.updateGridRow(index, quantity: quantity);
              },
            )),
          ),
          // Weight
          Expanded(
            flex: 2,
            child: Obx(() => TextFormField(
              initialValue: row.weight.value == 0 ? '' : row.weight.value.toString(),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final weight = double.tryParse(value) ?? 0.0;
                controller.updateGridRow(index, weight: weight);
              },
            )),
          ),
          // Rate
          Expanded(
            flex: 2,
            child: Obx(() => TextFormField(
              initialValue: row.rate.value == 0 ? '' : row.rate.value.toString(),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final rate = double.tryParse(value) ?? 0.0;
                controller.updateGridRow(index, rate: rate);
              },
            )),
          ),
          // Amount
          Expanded(
            flex: 2,
            child: Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                row.amount.value.toStringAsFixed(2),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildAddRowButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => controller.addBlankRow(),
        icon: const Icon(Icons.add),
        label: const Text('Add Row'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSignatureSection() {
    return Row(
      children: [
        // Recipient Signature
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recipient Signature:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: controller.recipientSignatureController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Sign here...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Sender Signature
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sender Signature:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: controller.senderSignatureController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Sign here...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Print Status
        Obx(() => controller.printStatus.value.isNotEmpty
            ? Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              controller.isDiscovering.value || controller.isPrinting.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(controller.printStatus.value)),
            ],
          ),
        )
            : const SizedBox()),

        // Action Buttons Row
        Row(
          children: [
            // Save Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.saveSlip(),
                icon: const Icon(Icons.save),
                label: const Text('Save Slip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Print Button
            Expanded(
              child: Obx(() => ElevatedButton.icon(
                onPressed: controller.isPrinting.value
                    ? null
                    : () => _showPrintDialog(),
                icon: controller.isPrinting.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.print),
                label: Text(controller.isPrinting.value ? 'Printing...' : 'Print Slip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Discover Printers Button
        Obx(() => ElevatedButton.icon(
          onPressed: controller.isDiscovering.value
              ? null
              : () => controller.discoverPrinters(),
          icon: controller.isDiscovering.value
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.search),
          label: Text(controller.isDiscovering.value
              ? 'Discovering...'
              : 'Discover Printers'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        )),
      ],
    );
  }
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.selectDate(picked);
    }
  }

  void _showPrintDialog() {
    if (controller.discoveredPrinters.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text('No Printers Found'),
          content: const Text('Would you like to discover printers on the network first?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.discoverPrinters();
              },
              child: const Text('Discover'),
            ),
          ],
        ),
      );
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text('Select Printer'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.discoveredPrinters.length,
              itemBuilder: (context, index) {
                final printer = controller.discoveredPrinters[index];
                return ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(printer.name),
                  subtitle: Text('${printer.ip}:${printer.port}'),
                  onTap: () {
                    Get.back();
                    controller.printSlip(printer);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.printSlip(); // Print to first available printer
              },
              child: const Text('Print to First'),
            ),
          ],
        ),
      );
    }
  }


}

