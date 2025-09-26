import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'salesman.dart';
import 'salesman_controller.dart';

class SalesmanForm extends StatefulWidget {
  final Salesman? salesman; // null = add new

  SalesmanForm({this.salesman});

  @override
  _SalesmanFormState createState() => _SalesmanFormState();
}

class _SalesmanFormState extends State<SalesmanForm> {
  final _formKey = GlobalKey<FormState>();
  final SalesmanController controller = Get.find();

  late TextEditingController nameController;
  late TextEditingController commissionController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.salesman?.name ?? '');
    commissionController = TextEditingController(
        text: widget.salesman?.commission?.toString() ?? '');
    phoneController = TextEditingController(text: widget.salesman?.phone ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    commissionController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newSalesman = Salesman(
        id: widget.salesman?.id ?? 0, // id ignored on creation
        name: nameController.text.trim(),
        commission: commissionController.text.isEmpty
            ? null
            : double.tryParse(commissionController.text.trim()),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
      );
      controller.addOrUpdateSalesman(widget.salesman, newSalesman);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.salesman == null ? 'Add Salesman' : 'Edit Salesman'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Name is required' : null,
              ),
              TextFormField(
                controller: commissionController,
                decoration: InputDecoration(labelText: 'Commission'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return double.tryParse(value.trim()) == null ? 'Enter a valid number' : null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
        Obx(() {
          return controller.isLoading.value
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
              : TextButton(
            onPressed: _submit,
            child: Text('Save'),
          );
        }),
      ],
    );
  }
}
