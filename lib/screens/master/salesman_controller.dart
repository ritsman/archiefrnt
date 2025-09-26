import 'package:get/get.dart';
import 'salesman.dart';
import 'api_service.dart';

class SalesmanController extends GetxController {
  //var salesmen=Salesman(id: 12, name: 'Rite',commission: 50,phone: '1234').obs;
  var salesmen = <Salesman>[Salesman(id: 12, name: 'Rite',commission: 50,phone: '1234')].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    refreshSalesmen();
    super.onInit();
  }

  void refreshSalesmen() async {
    try {
      isLoading.value = true;
      final data = await ApiService.fetchSalesmen();
      salesmen.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Could not load salesmen: $e');

    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOrUpdateSalesman(Salesman? oldSalesman, Salesman newSalesman) async {
    try {
      isLoading.value = true;
      if (oldSalesman == null) {
        // Create new

        final created = await ApiService.createSalesman(newSalesman);
        salesmen.add(created);
      } else {
        // Update existing

        final updated = await ApiService.updateSalesman(oldSalesman.id, newSalesman);
        int index = salesmen.indexWhere((s) => s.id == oldSalesman.id);
        if (index != -1) {
          salesmen[index] = updated;
        }
      }
      Get.back(); // Close dialog/page after success
      Get.snackbar('Success', 'Salesman saved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save salesman: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSalesman(int id) async {
    try {
      isLoading.value = true;
      await ApiService.deleteSalesman(id);
      salesmen.removeWhere((s) => s.id == id);
      Get.snackbar('Deleted', 'Salesman deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete salesman: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
