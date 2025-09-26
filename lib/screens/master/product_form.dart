import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_controller.dart';
import 'product.dart';

class ProductForm extends StatefulWidget {
  final Product? product;
  ProductForm({this.product});
  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final ProductController controller = Get.find();

  late TextEditingController nameController;
  late TextEditingController weightController;
  late TextEditingController rateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?.name ?? '');
    weightController = TextEditingController(text: widget.product?.weight?.toString() ?? '');
    rateController = TextEditingController(text: widget.product?.rate?.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newProduct = Product(
        id: widget.product?.id ?? 0,
        name: nameController.text.trim(),
        weight: weightController.text.isEmpty ? null : double.tryParse(weightController.text),
        rate: rateController.text.isEmpty ? null : double.tryParse(rateController.text),
      );
      controller.addOrUpdateProduct(widget.product, newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              TextFormField(
                controller: weightController,
                decoration: InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return double.tryParse(v) == null ? 'Enter a valid number' : null;
                },
              ),
              TextFormField(
                controller: rateController,
                decoration: InputDecoration(labelText: 'Rate'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return double.tryParse(v) == null ? 'Enter a valid number' : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
        Obx(() => controller.isLoading.value
            ? Padding(
          padding: const EdgeInsets.all(8.0),
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
