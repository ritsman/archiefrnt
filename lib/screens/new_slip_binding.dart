import 'package:get/get.dart';

import 'new_slip_controller.dart';

class NewSlipBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewSlipController>(() => NewSlipController());
  }
}
