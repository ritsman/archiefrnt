import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'master/client.dart';    // your client model
import 'master/salesman.dart'; // your salesman model
import 'master/product.dart';  // your product model
import 'slip.dart';
import 'slip_details.dart'; // model for slip detail item
import 'master/api_service.dart';     // your API service

class NewSlipController extends GetxController {
  // Section 1 fields
  var slipDate = DateTime.now().obs;
  var slipNumber = ''.obs;

  var vehicleNumberController = TextEditingController();
  var vehicleNumberSuggestions = <String>[].obs;

  // Clients & Salesmen list and selection
  var clients = <Client>[].obs;
  var selectedClient = Rxn<Client>();
  var products = <Product>[].obs;
  var salesmen = <Salesman>[].obs;
  var selectedSalesman = Rxn<Salesman>();

  // Section 2: slip details list
  var slipDetails = <SlipDetail>[].obs;

  // Section 3: summary values
  RxDouble totalWeight = 0.0.obs;
  RxInt totalQuantity = 0.obs;
  RxDouble totalAmount = 0.0.obs;

  // Loading and UI feedback
  var isSaving = false.obs;

  // Initialize lists of clients, salesmen, products, vehicle numbers, etc.
  @override
  void onInit() {
    super.onInit();
    fetchInitialData();

    vehicleNumberController.addListener(() {
      filterVehicleNumberSuggestions(vehicleNumberController.text);
    });
  }

  Future<void> fetchInitialData() async {
    try {
      // Fetch clients, salesmen etc. from your API
      clients.assignAll(await ApiService.fetchClients());
      salesmen.assignAll(await ApiService.fetchSalesmen());
      products.assignAll(await ApiService.fetchProducts());

      // For vehicle numbers, gather the unique numbers from previous slips or elsewhere
      vehicleNumberSuggestions.assignAll(await ApiService.fetchVehicleNumbers());

      // Generate slip number for today (can also be updated by user if needed)
      slipNumber.value = await ApiService.generateSlipNumber(slipDate.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load initial data: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void filterVehicleNumberSuggestions(String input) {
    if (input.isEmpty) {
      vehicleNumberSuggestions.value = vehicleNumberSuggestions.toSet().toList();
    } else {
      final lowerInput = input.toLowerCase();
      vehicleNumberSuggestions.value = vehicleNumberSuggestions
          .where((v) => v.toLowerCase().contains(lowerInput))
          .toSet()
          .toList();
    }
  }

  void updateSlipDate(DateTime newDate) async {
    slipDate.value = newDate;
    slipNumber.value = await ApiService.generateSlipNumber(newDate);
  }

  // Section 2: Add, update, delete slip detail item

  void addNewSlipDetail() {
    slipDetails.add(SlipDetail(
      id: 0,
      product: null,
      quantity: 1,
      rate: 0.0,
      weight: 0.0,
      amount: 0.0,
    ));
    calculateSummary();
  }

  void updateSlipDetail(int index, SlipDetail detail) {
    slipDetails[index] = detail;
    calculateSummary();
  }

  void deleteSlipDetail(int index) {
    slipDetails.removeAt(index);
    calculateSummary();
  }

  void calculateSummary() {
    double weightSum = 0;
    int qtySum = 0;
    double amountSum = 0;
    for (var d in slipDetails) {
      weightSum += d.weight ?? 0;
      qtySum += d.quantity ?? 0;
      amountSum += d.amount ?? 0;
    }
    totalWeight.value = weightSum;
    totalQuantity.value = qtySum;
    totalAmount.value = amountSum;
  }

  void onProductSelected(int index, Product product) {
    var detail = slipDetails[index];
    // Update product, and fetch rate from DB (already have product.rate)
    detail = detail.copyWith(
      product: product,
      rate: product.rate ?? 0,
      // optionally reset quantity, weight, amount
    );
    slipDetails[index] = detail;
    calculateLineAmount(index);
    calculateSummary();
  }

  void onQuantityChanged(int index, int qty) {
    var detail = slipDetails[index];
    detail = detail.copyWith(quantity: qty);
    slipDetails[index] = detail;
    calculateLineAmount(index);
    calculateSummary();
  }

  void onRateChanged(int index, double rate) {
    var detail = slipDetails[index];
    detail = detail.copyWith(rate: rate);
    slipDetails[index] = detail;
    calculateLineAmount(index);
    calculateSummary();
  }

  void calculateLineAmount(int index) {
    var detail = slipDetails[index];
    double weight = 0;
    if (detail.product?.weight != null && detail.quantity != null) {
      weight = detail.product!.weight! * detail.quantity!;
    }
    double amount = (detail.rate ?? 0) * (detail.quantity ?? 0);

    detail = detail.copyWith(weight: weight, amount: amount);
    slipDetails[index] = detail;
  }

  // Submit slip data

  Future<void> saveSlip({bool print = false}) async {
    if (selectedClient.value == null) {
      Get.snackbar('Validation Error', 'Please select a client', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedSalesman.value == null) {
      Get.snackbar('Validation Error', 'Please select a salesman', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (slipDetails.isEmpty) {
      Get.snackbar('Validation Error', 'Please add at least one slip detail', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;

    try {
      List<SlipDetail> slipDetailsWithDate = slipDetails.map((detail) {
        return detail.copyWith(slipDate: slipDate.value);
      }).toList();
      // Build slip create object with nested details
      var slipCreate = Slip(
        id: 0,
        slipNumber: slipNumber.value,
        clientId: selectedClient.value!.id,
        salesmanId: selectedSalesman.value!.id,
        slipDate: slipDate.value,
        vehicleNumber: vehicleNumberController.text,
        totalAmount: totalAmount.value,
        slipDetails: slipDetailsWithDate,
      );

      // Save via API
      await ApiService.createSlip(slipCreate);

      Get.snackbar('Success', 'Slip saved successfully', snackPosition: SnackPosition.BOTTOM);

      if (print) {
        // Call your print function here, or open printer selection dialog
        // Implement printer logic below
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save slip: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> findAndSelectPrinter() async {
    // Your printer discovery logic here
    // Could open a modal dialog that allows user to scan/select printers
    // For now just a placeholder
    Get.snackbar('Info', 'Printer selection not implemented yet', snackPosition: SnackPosition.BOTTOM);
  }
}
