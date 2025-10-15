import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'master/client.dart';
import 'master/salesman.dart';
import 'master/product.dart';
import 'slip.dart';
import 'slip_details.dart';
import 'master/api_service.dart';

class NewSlipController extends GetxController {
  // Section 1: Basic fields
  var slipDate = DateTime.now().obs;
  var slipNumber = ''.obs;

  var vehicleNumberController = TextEditingController();
  var vehicleNumberSuggestions = <String>[].obs;

  // NEW: Transport Charges
  var transportCharges = 0.0.obs;
  late TextEditingController transportChargesController;

  // Clients, Salesmen, Products
  var clients = <Client>[].obs;
  var selectedClient = Rxn<Client>();
  var products = <Product>[].obs;
  var salesmen = <Salesman>[].obs;
  var selectedSalesman = Rxn<Salesman>();

  // Section 2: Slip details
  var slipDetails = <SlipDetail>[].obs;
  var quantityControllers = <TextEditingController>[].obs;
  var rateControllers = <TextEditingController>[].obs;

  // Section 3: Summary values
  RxDouble totalWeight = 0.0.obs;
  RxDouble totalQuantity = 0.0.obs;
  RxDouble totalAmount = 0.0.obs;

  // Loading/UI feedback
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    initializeControllers();

    vehicleNumberController.addListener(() {
      filterVehicleNumberSuggestions(vehicleNumberController.text);
    });

    // Initialize transport controller
    transportChargesController = TextEditingController();
  }

  @override
  void onClose() {
    vehicleNumberController.dispose();
    transportChargesController.dispose();
    for (var c in quantityControllers) {
      c.dispose();
    }
    for (var c in rateControllers) {
      c.dispose();
    }
    super.onClose();
  }

  void initializeControllers() {
    quantityControllers.clear();
    rateControllers.clear();
    for (var slip in slipDetails) {
      quantityControllers.add(
          TextEditingController(text: slip.quantity?.toString() ?? ''));
      rateControllers
          .add(TextEditingController(text: slip.rate?.toString() ?? ''));
    }
  }

  Future<void> fetchInitialData() async {
    try {
      clients.assignAll(await ApiService.fetchClients());
      salesmen.assignAll(await ApiService.fetchSalesmen());
      products.assignAll(await ApiService.fetchProducts());
      vehicleNumberSuggestions.assignAll(await ApiService.fetchVehicleNumbers());
      slipNumber.value = await ApiService.generateSlipNumber(slipDate.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load initial data: $e',
          snackPosition: SnackPosition.BOTTOM);
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

  // Slip details handling
  void addNewSlipDetail() {
    slipDetails.add(SlipDetail(
      id: 0,
      product: null,
      quantity: 1,
      rate: 0.0,
      weight: 0.0,
      amount: 0.0,
    ));
    quantityControllers.add(TextEditingController(text: '1'));
    rateControllers.add(TextEditingController(text: '0.0'));
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
    double qtySum = 0;
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
    var detail = slipDetails[index].copyWith(
      product: product,
      rate: product.rate ?? 0,
    );
    slipDetails[index] = detail;
    rateControllers[index].text = (product.rate ?? 0).toString();
    calculateLineAmount(index);
    calculateSummary();
  }

  void onQuantityChanged(int index, double qty) {
    slipDetails[index] = slipDetails[index].copyWith(quantity: qty);
    calculateLineAmount(index);
    calculateSummary();
  }

  void onRateChanged(int index, double rate) {
    slipDetails[index] = slipDetails[index].copyWith(rate: rate);
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
    slipDetails[index] = detail.copyWith(weight: weight, amount: amount);
  }

  // Save Slip
  Future<void> saveSlip({bool print = false}) async {
    if (selectedClient.value == null) {
      Get.snackbar('Validation Error', 'Please select a client',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedSalesman.value == null) {
      Get.snackbar('Validation Error', 'Please select a salesman',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (slipDetails.isEmpty) {
      Get.snackbar('Validation Error', 'Please add at least one slip detail',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;

    try {
      List<SlipDetail> slipDetailsWithDate = slipDetails.map((detail) {
        return detail.copyWith(slipDate: slipDate.value);
      }).toList();

      var slipCreate = Slip(
        id: 0,
        slipNumber: slipNumber.value,
        clientId: selectedClient.value!.id,
        salesmanId: selectedSalesman.value!.id,
        slipDate: slipDate.value,
        vehicleNumber: vehicleNumberController.text,
        transportCharges:transportCharges.value,
        totalAmount: totalAmount.value , // ✅ include
        slipDetails: slipDetailsWithDate,
        // optionally: add transportCharges in your Slip model if backend supports it
      );

      await ApiService.createSlip(slipCreate);

      Get.snackbar('Success', 'Slip saved successfully',
          snackPosition: SnackPosition.BOTTOM);

      if (print) {
        // implement printing here
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save slip: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> findAndSelectPrinter() async {
    Get.snackbar('Info', 'Printer selection not implemented yet',
        snackPosition: SnackPosition.BOTTOM);
  }
}
