import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddNewClientController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  var isLoading = false.obs;

  // Replace with your actual FastAPI backend URL
  final String baseUrl = 'http://your-fastapi-backend.com';

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> saveClient() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      final clientData = {
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'address': addressController.text.trim(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/clients'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(clientData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Client saved successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Clear form after successful save
        nameController.clear();
        mobileController.clear();
        addressController.clear();

        // Optional: Navigate back
        // Get.back();
      } else {
        throw Exception('Failed to save client');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error saving client: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class AddNewClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddNewClientController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Client'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Client Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: controller.mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter valid mobile number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: controller.addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: controller.isLoading.value
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('Saving...'),
                  ],
                )
                    : Text('Save Client'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}