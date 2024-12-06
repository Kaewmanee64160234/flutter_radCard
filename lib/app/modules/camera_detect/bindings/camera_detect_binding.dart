import 'package:get/get.dart';
import 'package:read_card/app/modules/camera_detect/controllers/tensor_image_controller.dart';

import '../controllers/camera_detect_controller.dart';

class CameraDetectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraDetectController>(
      () => CameraDetectController(),
    );
    Get.lazyPut(() => TensorflowController());
  }
}
