import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class ScreenScaleController extends GetxController {
  RxDouble scaleX = (0.0).obs;
  RxDouble scaleY = (0.0).obs;

  RxDouble frameLeft = (0.0).obs;
  RxDouble frameTop = (0.0).obs;
  RxDouble frameWidth = (0.0).obs;
  RxDouble frameHeight = (0.0).obs;

  RxBool isProcessing = false.obs;

  void setScale(img.Image capturedImage) {
    double scaleX = capturedImage.width / frameWidth.value;
    double scaleY = capturedImage.height / frameHeight.value;

    this.scaleX.value = scaleX;
    this.scaleY.value = scaleY;

    print("ScaleX: $scaleX, ScaleY: $scaleY");
  }
}
