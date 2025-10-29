import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'master/client.dart';
import 'master/salesman.dart';
import 'master/product.dart';
import 'slip.dart';
import 'slip_details.dart';
import 'master/api_service.dart';

class NewSlipController extends GetxController {
  //Slip? editingSlip;
  late final Rxn<Slip> editingSlipRx = Rxn<Slip>(null);

  // Section 1: Basic fields
  var slipDate = DateTime.now().obs;
  var slipNumber = ''.obs;

  var vehicleNumberController = TextEditingController();
  var vehicleNumberSuggestions = <String>[].obs;

  // NEW: Transport Charges
  var transportCharges = 0.0.obs;
  var transportChargesController=TextEditingController();

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
  RxDouble totalAmount = 14.0.obs;

  // Loading/UI feedback
  var isSaving = false.obs;
  var slipNumberController = TextEditingController();
  var totalWeightController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    print('🧭 NewSlipController created: $hashCode');
    slipNumber.listen((value) {
      slipNumberController.text = value;
    });

    totalWeight.listen((value) {
      totalWeightController.text = value.toStringAsFixed(2);
    });
    // Check if a slip was passed
    final Slip? slipArg = Get.arguments as Slip?;
    if (slipArg != null) {
      // Editing existing slip
      print("edit mode....$slipArg");
      editingSlipRx.value = slipArg;
      fetchInitialDataforEdit(slipArg);

    } else {
      // Creating new slip
      print("R:new slip");
      fetchInitialData();

      vehicleNumberController.addListener(() {
        filterVehicleNumberSuggestions(vehicleNumberController.text);
      });

      // Initialize transport controller
      //if(transportChargesController==null){
      transportChargesController = TextEditingController();
      transportChargesController.text = transportCharges.value == 0.0
          ? ''
          : transportCharges.value.toStringAsFixed(2);

      // ✅ Add listener for transport charges
      transportChargesController.addListener(() {
        final parsed =
            double.tryParse(transportChargesController.text.trim()) ?? 0.0;
        transportCharges.value = parsed;
        calculateSummary(parsed);
      });
      //}
    }
  }

  @override
  void onClose() {
    //vehicleNumberController.dispose();
    transportChargesController.dispose();
    // Dispose the new controllers
    slipNumberController.dispose();
    totalWeightController.dispose();
    for (var c in quantityControllers) {
      c.dispose();
    }
    for (var c in rateControllers) {
      c.dispose();
    }
    print('❌ NewSlipController disposed: $hashCode');
    super.onClose();

  }

  void initializeControllers() {
    quantityControllers.clear();
    rateControllers.clear();

    for (var slip in slipDetails) {
      quantityControllers
          .add(TextEditingController(text: slip.quantity?.toString() ?? ''));
      rateControllers
          .add(TextEditingController(text: slip.rate?.toString() ?? ''));
    }
  }
  Future<void>fetchInitialDataforEdit(slipArg)async{
    try {
      clients.assignAll(await ApiService.fetchClients());
      salesmen.assignAll(await ApiService.fetchSalesmen());
      products.assignAll(await ApiService.fetchProducts());
      populateFromSlip(slipArg);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load initial data: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  Future<void> fetchInitialData() async {
    try {
      clients.assignAll(await ApiService.fetchClients());
      salesmen.assignAll(await ApiService.fetchSalesmen());
      products.assignAll(await ApiService.fetchProducts());
      vehicleNumberSuggestions
          .assignAll(await ApiService.fetchVehicleNumbers());
      slipNumber.value = await ApiService.generateSlipNumber(slipDate.value);
      slipNumberController.text = slipNumber.value; // Set initial text
    } catch (e) {
      Get.snackbar('Error', 'Failed to load initial data: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void filterVehicleNumberSuggestions(String input) {
    if (input.isEmpty) {
      vehicleNumberSuggestions.value =
          vehicleNumberSuggestions.toSet().toList();
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
    slipNumberController.text = slipNumber.value; // Set initial text
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

    calculateSummary(transportCharges.value);
  }

  void updateSlipDetail(int index, SlipDetail detail) {
    slipDetails[index] = detail;
    calculateSummary(transportCharges.value);
  }

  void deleteSlipDetail(int index) {
    slipDetails.removeAt(index);
    calculateSummary(transportCharges.value);
  }

  void calculateSummary(transportCharges) {
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
    totalAmount.value = amountSum + transportCharges;
    totalWeightController.text = totalWeight.value.toStringAsFixed(2);
  }

  void populateFromSlip(Slip slip) {
    print(slip);

    slipDate.value = slip.slipDate;
    slipNumber.value = slip.slipNumber;
    selectedClient.value =
        clients.firstWhereOrNull((c) => c.id == slip.clientId);
    selectedSalesman.value =
        salesmen.firstWhereOrNull((s) => s.id == slip.salesmanId);
    vehicleNumberController.text = slip.vehicleNumber ?? '';
    transportCharges.value = slip.transportCharges ?? 0.0;
    transportChargesController.text = transportCharges.value == 0.0
        ? ''
        : transportCharges.value.toStringAsFixed(2); // Fill the UI field
    totalAmount.value = slip.totalAmount;
    slipDetails.assignAll(slip.slipDetails);
    initializeControllers();
    calculateSummary(slip.transportCharges);
  }

  void onProductSelected(int index, Product product) {
    var detail = slipDetails[index].copyWith(
      product: product,
      rate: product.rate ?? 0,
    );
    slipDetails[index] = detail;
    rateControllers[index].text = (product.rate ?? 0).toString();
    calculateLineAmount(index);
    calculateSummary(transportCharges.value);
  }

  void onQuantityChanged(int index, double qty) {
    slipDetails[index] = slipDetails[index].copyWith(quantity: qty);
    calculateLineAmount(index);
    calculateSummary(transportCharges.value);
  }

  void onRateChanged(int index, double rate) {
    slipDetails[index] = slipDetails[index].copyWith(rate: rate);
    calculateLineAmount(index);
    calculateSummary(transportCharges.value);
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
  Future<void> saveSlip({bool shouldPrint = false}) async {
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
      final int slipId = editingSlipRx.value?.id ?? 0;
      var slipCreate = Slip(
        id: slipId,
        slipNumber: slipNumber.value,
        clientId: selectedClient.value!.id,
        salesmanId: selectedSalesman.value!.id,
        slipDate: slipDate.value,
        vehicleNumber: vehicleNumberController.text,
        transportCharges: transportCharges.value,
        totalAmount: totalAmount.value, // ✅ include
        slipDetails: slipDetailsWithDate,
        // optionally: add transportCharges in your Slip model if backend supports it
      );

      // 2. Call the appropriate API function
      if (editingSlipRx.value != null) {
        Slip savedSlip;
        // --- EDIT MODE: Call updateSlip ---
        print('STEP 1: Starting API call...');
        savedSlip=await ApiService.updateSlip(slipId, slipCreate);
        print('STEP 2: API call finished successfully!');
        try {
          print('STEP 3: Starting State Update...');
          editingSlipRx.value = savedSlip; // 🛑 Suspected crash point
          print('STEP 4: State Update finished.'); // ❓ This may not print
        } catch (e) {
          // This is a safety net for any synchronous error during assignment
          print('CRITICAL SYNC ASSIGNMENT ERROR: $e');
        }
        print('STEP 5: Attempting Snackbar...');
        Get.snackbar('Success', 'Slip updated successfully',
            snackPosition: SnackPosition.BOTTOM); // ❓ This may not run
        await Future.delayed(const Duration(milliseconds: 5000)); // Add a tiny pause
        print('STEP 6: Attempting Navigation...');
        Get.back(); // ❓ This may not run

        print('STEP 7: Function exit.');
      } else {
        // --- NEW SLIP MODE: Call createSlip ---
        await ApiService.createSlip(slipCreate);
        Get.snackbar('Success', 'Slip saved successfully',
            snackPosition: SnackPosition.BOTTOM);
      }

      if (shouldPrint) {
        // implement printing here
      }
    } catch (e,stackTrace) {
      print('error:$e');
      print("------");
      print('Call Stack: $stackTrace');
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
