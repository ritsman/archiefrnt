import 'package:get/get.dart';
import 'client.dart';
import 'api_service.dart';

class ClientController extends GetxController {
  var clients = <Client>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    refreshClients();
    super.onInit();
  }

  void refreshClients() async {
    try {
      isLoading.value = true;
      final data = await ApiService.fetchClients();
      clients.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Could not load clients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOrUpdateClient(Client? oldClient, Client newClient) async {
    try {
      isLoading.value = true;
      if (oldClient == null) {
        final created = await ApiService.createClient(newClient);
        clients.add(created);
      } else {
        final updated = await ApiService.updateClient(oldClient.id, newClient);
        int index = clients.indexWhere((c) => c.id == oldClient.id);
        if (index != -1) {
          clients[index] = updated;
        }
      }
      Get.back();
      Get.snackbar('Success', 'Client saved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save client: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      isLoading.value = true;
      await ApiService.deleteClient(id);
      clients.removeWhere((c) => c.id == id);
      Get.snackbar('Deleted', 'Client deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete client: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
