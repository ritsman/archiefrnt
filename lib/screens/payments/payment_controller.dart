import 'package:get/get.dart';
import 'payments.dart';
import '../master/api_service.dart';
class PaymentController extends GetxController {
  var payments = <Payment>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      isLoading.value = true;
      // Fetch payments with limit 100 from your API
      final fetched = await ApiService.fetchPayments(limit: 100);
      payments.assignAll(fetched);
    } catch (e) {
      Get.snackbar("Error", "Failed to load payments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPayment(int clientId, double amount, String? notes,DateTime date) async {
    try {
      final newPay = await ApiService.createPayment(
          clientId: clientId, amount: amount, notes: notes,date:date);
      payments.insert(0, newPay);
      Get.snackbar("Success", "Payment added successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to add payment: $e");
    }
  }

  Future<void> updatePayment(Payment payment) async {
    try {
      final updatedPay = await ApiService.updatePayment(
        id: payment.id,
        clientId: payment.client.id,
        amount: payment.amount,
        notes: payment.notes,
        date: payment.date,
      );

      // Replace the old payment in the list
      final index = payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        payments[index] = updatedPay;
      }

      Get.snackbar("Success", "Payment updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update payment: $e");
    }
  }


  Future<void> deletePayment(Payment payment) async {
    try {
      await ApiService.deletePayment(payment.id);
      payments.remove(payment);
      Get.snackbar("Deleted", "Payment deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete payment: $e");
    }
  }

}
