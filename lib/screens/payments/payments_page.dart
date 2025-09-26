import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // for date formatting
import '../slip.dart';
import 'payments.dart';
import 'payment_controller.dart';
import '../master/client_controller.dart';


class PaymentsScreen extends StatelessWidget {
  final PaymentController paymentController = Get.put(PaymentController());
  final ClientController clientController = Get.put(ClientController());

  PaymentsScreen({super.key});
  void _showAddOrEditDialog({Payment? payment}) async {
    // Ensure clients are loaded
    if (clientController.clients.isEmpty) {
      clientController.refreshClients();
    }
    // Track selected client and its ID separately
    ClientMini? selectedClient = payment?.client;
    int? selectedClientId = payment?.client.id;

    final amountController = TextEditingController(text: payment?.amount.toString() ?? "");
    final notesController = TextEditingController(text: payment?.notes ?? "");
    DateTime selectedDate = payment?.date ?? DateTime.now();

    Get.defaultDialog(
      title: payment == null ? "Add Payment" : "Edit Payment",
      content: Obx(() {
        if (clientController.clients.isEmpty) {
          return const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              // Client Dropdown
              DropdownButtonFormField<int>(
                value: selectedClientId,
                hint: const Text("Select Client"),
                isExpanded: true,
                onChanged: (int? id) {
                  if (id != null) {
                    selectedClientId = id;
                    final client = clientController.clients.firstWhere((c) => c.id == id);
                    selectedClient = ClientMini(id: client.id, name: client.name);
                  }
                },
                items: clientController.clients.map((client) => DropdownMenuItem<int>(
                  value: client.id,
                  child: Text(client.name),
                )).toList(),
              ),

              const SizedBox(height: 8),

              // Amount field
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),

              const SizedBox(height: 8),

              // Date picker
              Row(
                children: [
                  Expanded(
                    child: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                        // Refresh the dialog to show new date
                        Get.back();
                        _showAddOrEditDialog(
                          payment: payment?.copyWith(
                            client: selectedClient,
                            amount: double.tryParse(amountController.text) ?? 0,
                            notes: notesController.text,
                            date: selectedDate,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              // Notes field
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
            ],
          ),
        );
      }),
      textConfirm: "Save",
      textCancel: "Cancel",
      onConfirm: () {
        final amount = double.tryParse(amountController.text.trim());
        final notes = notesController.text.trim();

        if (selectedClient != null && amount != null) {
          if (payment == null) {
            // Add new payment
            paymentController.addPayment(
              selectedClient!.id,
              amount,
              notes,
              selectedDate,
            );
          } else {
            // Update existing payment
            paymentController.updatePayment(
              payment.copyWith(
                client: selectedClient!,
                amount: amount,
                notes: notes,
                date: selectedDate,
              ),
            );
          }
          Get.back();
        } else {
          Get.snackbar("Error", "Please select a client and enter amount");
        }
      },
    );
  }

  void _showAddOrEditDialog2({Payment? payment}) async {
    print(payment.toString());
    // Ensure clients are loaded
    if (clientController.clients.isEmpty) {
      clientController.refreshClients();
    }

    ClientMini? selectedClient = payment?.client;
    final amountController =
    TextEditingController(text: payment?.amount.toString() ?? "");
    final notesController =
    TextEditingController(text: payment?.notes ?? "");

    // Date selection
    DateTime selectedDate =
        payment?.date ?? DateTime.now(); // default to today

    Get.defaultDialog(
      title: payment == null ? "Add Payment" : "Edit Payment",
      content: Obx(() {
        if (clientController.clients.isEmpty) {
          return const SizedBox(
              height: 80, child: Center(child: CircularProgressIndicator()));
        }
        return SingleChildScrollView(
          child: Column(

            children: [
              // Client Dropdown
              DropdownButtonFormField<int>(
                value: selectedClient?.id,
                hint: const Text("Select Client"),
                isExpanded: true,
                onChanged: (int? id) {
                  if (id != null) {
                    selectedClient = clientController.clients.firstWhere((c) => c.id == id) as ClientMini?;
                  }
                },
                items: clientController.clients
                    .map((client) => DropdownMenuItem<int>(
                  value: client.id,
                  child: Text(client.name),
                ))
                    .toList(),
              ),

              const SizedBox(height: 8),

              // Amount field
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),

              const SizedBox(height: 8),

              // Date picker
              Row(
                children: [
                  Expanded(
                    child: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: Get.context!,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        selectedDate = picked;
                        // hack to refresh dialog content
                        Get.back();
                        _showAddOrEditDialog(payment: payment?.copyWith(
                          client: selectedClient,
                          amount: double.tryParse(amountController.text) ?? 0,
                          notes: notesController.text,
                          date: selectedDate,
                        ));
                      }
                    },
                  ),
                ],
              ),

              // Notes field
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
            ],
          ),
        );
      }),
      textConfirm: "Save",
      textCancel: "Cancel",
      onConfirm: () {
        final amount = double.tryParse(amountController.text.trim());
        final notes = notesController.text.trim();

        if (selectedClient != null && amount != null) {
          if (payment == null) {
            paymentController.addPayment(
              selectedClient!.id,
              amount,
              notes,
              selectedDate,
            );
          } else {
            paymentController.updatePayment(
              payment.copyWith(
                client: selectedClient!,
                amount: amount,
                notes: notes,
                date: selectedDate,
              ),
            );
          }
          Get.back();
        } else {
          Get.snackbar("Error", "Please select a client and enter amount");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Payment",
            onPressed: () => _showAddOrEditDialog(),
          ),
        ],
      ),
      body: Obx(() {
        if (paymentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (paymentController.payments.isEmpty) {
          return const Center(child: Text("No payments found"));
        }
        return ListView.builder(
          itemCount: paymentController.payments.length,
          itemBuilder: (context, index) {
            final payment = paymentController.payments[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(payment.client.name.isNotEmpty
                      ? payment.client.name[0].toUpperCase()
                      : "?"),
                ),
                title: Text(payment.client.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Amount: ₹${payment.amount.toStringAsFixed(2)}"),
                    Text("Date: ${DateFormat('yyyy-MM-dd').format(payment.date)}"),
                    if (payment.notes != null && payment.notes!.trim().isNotEmpty)
                      Text("Notes: ${payment.notes}"),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddOrEditDialog(payment: payment);
                    } else if (value == 'delete') {
                      paymentController.deletePayment(payment);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
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
