import 'package:get/get.dart';

import '../modules/camera_detect/bindings/camera_detect_binding.dart';
import '../modules/camera_detect/views/camera_detect_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/process_image/bindings/process_image_binding.dart';
import '../modules/process_image/views/process_image_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROCESS_IMAGE,
      page: () => const ProcessImageView(),
      binding: ProcessImageBinding(),
    ),
    GetPage(
      name: _Paths.CAMERA_DETECT,
      page: () => const CameraDetectView(),
      binding: CameraDetectBinding(),
    ),
  ];
}
