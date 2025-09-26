import 'package:get/get.dart';
import '../slip.dart';
import '../master/api_service.dart';

class DispatchController extends GetxController {
  var slips = <Slip>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSlips();
  }

  void fetchSlips() async {
    try {
      isLoading.value = true;
      final fetched = await ApiService.fetchSlips();
      print("---------");
      print(fetched);
      slips.assignAll(fetched);
    } catch (e) {
      Get.snackbar("Error", "Failed to load slips: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSlip(int id) async {
    isLoading.value = true;
    try {
      await ApiService.deleteSlip(id);
      slips.removeWhere((s) => s.id == id);
      Get.snackbar("Deleted", "Slip deleted", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete slip: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void printSlip(Slip slip) {
    // Integrate your actual print logic/printer plugin here
    Get.snackbar("Print", "Sending slip ${slip.slipNumber} to printer…", snackPosition: SnackPosition.BOTTOM);
    // TODO: implement print logic
  }

  void viewSlip(Slip slip) {
    // You can open a modal, show a dedicated details page, etc.
    Get.toNamed('/slip-view', arguments: slip); // OR use Get.dialog for modal
  }
}
