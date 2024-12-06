import 'package:get/get.dart';
import 'package:read_card/app/data/services/api_image_preprocessing_service.dart';
import 'package:read_card/app/data/services/api_ocr_credit_card_service.dart';

import '../controllers/process_image_controller.dart';

class ProcessImageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcessImageController>(
      () => ProcessImageController(),
    );
    Get.put<ApiImagePreprocessingService>(
      ApiImagePreprocessingService(),
    );
    Get.lazyPut(() => ApiOcrCreditCardService());
  }
}
