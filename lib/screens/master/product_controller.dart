import 'package:get/get.dart';
import 'product.dart';
import 'api_service.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    refreshProducts();
    super.onInit();
  }

  void refreshProducts() async {
    try {
      isLoading.value = true;
      final data = await ApiService.fetchProducts();
      products.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Could not load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOrUpdateProduct(Product? oldProduct, Product newProduct) async {
    try {
      isLoading.value = true;
      if (oldProduct == null) {
        final created = await ApiService.createProduct(newProduct);
        products.add(created);
      } else {
        final updated = await ApiService.updateProduct(oldProduct.id, newProduct);
        int index = products.indexWhere((p) => p.id == oldProduct.id);
        if (index != -1) products[index] = updated;
      }
      Get.back();
      Get.snackbar('Success', 'Product saved');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      isLoading.value = true;
      await ApiService.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      Get.snackbar('Deleted', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
