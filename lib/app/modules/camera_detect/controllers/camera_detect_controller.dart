import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:read_card/app/modules/camera_detect/controllers/tensor_image_controller.dart';
import 'screen_scale_controller.dart';

class CameraDetectController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  RxBool isCameraInitialized = false.obs;
  TensorflowController tensorflowController = Get.put(TensorflowController());
  ScreenScaleController screenScaleController =
      Get.put(ScreenScaleController());
  Timer? imageProcessingTimer;
  Timer? processingTimer;

  // Observable for card detection status
  RxBool isCardDetected = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await cameraController.initialize();
        isCameraInitialized.value = true;
      } else {
        print("No cameras found.");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void startImageStream() {
    if (!isCameraInitialized.value) return;

    cameraController.startImageStream((CameraImage image) async {
      if (processingTimer == null || !(processingTimer?.isActive ?? false)) {
        processingTimer =
            Timer.periodic(Duration(milliseconds: 500), (timer) async {
          try {
            Uint8List imageBytes = convertCameraImageToUint8List(image);
            await cropAndPredictImage(imageBytes);
          } catch (e) {
            print("Error processing stream: $e");
          }
        });
      }
    });
  }

  Future<void> cropAndPredictImage(Uint8List imageBytes) async {
    try {
      // Check if imageBytes is valid
      if (imageBytes.isEmpty) {
        print("Image bytes are empty or invalid.");
        return;
      }

      // Decode the image
      img.Image? capturedImage = img.decodeImage(imageBytes);
      if (capturedImage == null) {
        print("Failed to decode image.");
        return;
      }

      // Set scale based on the captured image dimensions
      screenScaleController.setScale(capturedImage);

      // Calculate cropping dimensions using the scale
      int cropX = (screenScaleController.frameLeft.value *
              screenScaleController.scaleX.value)
          .toInt();
      int cropY = (screenScaleController.frameTop.value *
              screenScaleController.scaleY.value)
          .toInt();
      int cropWidth = (screenScaleController.frameWidth.value *
              screenScaleController.scaleX.value)
          .toInt();
      int cropHeight = (screenScaleController.frameHeight.value *
              screenScaleController.scaleY.value)
          .toInt();

      // Ensure cropping dimensions are within the image bounds
      cropX = cropX.clamp(0, capturedImage.width);
      cropY = cropY.clamp(0, capturedImage.height);
      cropWidth = cropWidth.clamp(0, capturedImage.width - cropX);
      cropHeight = cropHeight.clamp(0, capturedImage.height - cropY);

      // Crop the image
      img.Image croppedImage =
          img.copyCrop(capturedImage, cropX, cropY, cropWidth, cropHeight);

      // Convert the cropped image to bytes
      Uint8List croppedImageBytes =
          Uint8List.fromList(img.encodeJpg(croppedImage));

      // Check if the TensorFlow model is loaded
      if (!tensorflowController.isModelLoaded) {
        print("TensorFlow model is not loaded.");
        return;
      }

      // Process the cropped image with the TensorFlow model
      int prediction =
          await tensorflowController.processImage(croppedImageBytes);

      // Update the predicted class observable
      tensorflowController.predictedClass.value = prediction;

      // Log the prediction
      print("Predicted Class: $prediction");

      // Optional: Save the cropped image for debugging purposes
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File file = File(filePath);
      await file.writeAsBytes(croppedImageBytes);

      print("Cropped image saved to: $filePath");

      // Detect if the card is within the frame
      if (prediction == 0) {
        print("Card detected in frame!");
      } else {
        print("Card not detected.");
      }
    } catch (e) {
      print("Error cropping or predicting: $e");
    }
  }

  Uint8List convertCameraImageToUint8List(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void stopImageStream() {
    processingTimer?.cancel();
    cameraController.stopImageStream();
    processingTimer = null;
    print("Image stream stopped.");
  }

  @override
  void onClose() {
    imageProcessingTimer?.cancel();
    cameraController.dispose();
    super.onClose();
  }
}
