import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/camera_detect_controller.dart';

class CameraDetectView extends GetView<CameraDetectController> {
  const CameraDetectView({super.key});

  @override
  Widget build(BuildContext context) {
    final CameraDetectController cameraController =
        Get.put(CameraDetectController());

    return Scaffold(
      appBar: AppBar(
        title: Text("ID Card Detection"),
      ),
      body: Obx(() {
        if (!cameraController.isCameraInitialized.value) {
          return Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            // Display the Camera Preview
            CameraPreview(cameraController.cameraController),

            // Overlay for ID Card Detection
            Center(
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: cameraController.isCardDetected.value
                        ? Colors.green
                        : Colors.red,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Display Predicted Class
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Obx(() => Text(
                      "Prediction: ${cameraController.tensorflowController.predictedClass.value}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cameraController.isCardDetected.value
                            ? Colors.green
                            : Colors.red,
                      ),
                    )),
              ),
            ),

            // Button to Start Streaming
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: cameraController.startImageStream,
                  child: Text("Start Streaming"),
                ),
              ),
            ),

            // Button to Stop Streaming
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: cameraController.stopImageStream,
                  child: Text("Stop Streaming"),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
