import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'client_controller.dart';
import 'client.dart';

class ClientForm extends StatefulWidget {
  final Client? client;

  ClientForm({this.client});

  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  final ClientController controller = Get.find();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.client?.name ?? '');
    phoneController = TextEditingController(text: widget.client?.phone ?? '');
    addressController = TextEditingController(text: widget.client?.address ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newClient = Client(
        id: widget.client?.id ?? 0,
        name: nameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
      );
      controller.addOrUpdateClient(widget.client, newClient);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.client == null ? 'Add Client' : 'Edit Client'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                keyboardType: TextInputType.streetAddress,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
        Obx(() => controller.isLoading.value
            ? Padding(
          padding: const EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        )
            : TextButton(
          onPressed: _submit,
          child: Text('Save'),
        )),
      ],
    );
  }
}
