import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:image/image.dart' as img; // To handle image processing
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorflowController extends GetxController {
  late Interpreter _interpreter;
  bool isModelLoaded = false;
  RxInt predictedClass = 2.obs;
  RxString guideMessage = "กรุณาวางบัตรในกรอบ".obs;
  String pleasePlaceCard = "กรุณาวางบัตรในกรอบ";
  String holdStill = "ถือนิ่งๆ";
  String success = "ได้รูปแล้ว";

  Future<void> loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/model_coco_mobile.tflite.tflite');
      isModelLoaded = true; // Set to true after model is successfully loaded
      print("TensorFlow Lite model loaded successfully.");
    } catch (e) {
      isModelLoaded = false;
      print("Error loading TensorFlow model: $e");
    }
  }

  // Helper function to load the model from the assets
  Future<ByteData> _loadModelFile(String path) async {
    final modelData = await rootBundle.load(path);
    return modelData;
  }

  Future<int> processImage(Uint8List imageBytes) async {
    try {
      // Decode the raw image bytes
      img.Image image = img.decodeImage(imageBytes)!;
      print("Image loaded successfully.");

      // Resize the image to match the model's input size
      const int height = 224;
      const int width = 224;
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height);
      print("Image resized to $width x $height.");

      // Prepare the image data in the required format for the model
      List<int> imageList = resizedImage.getBytes();
      Uint8List imageData = Uint8List.fromList(imageList);

      // Reshape the image to match the model input: [1, 224, 224, 3]
      List<List<List<List<int>>>> input = List.generate(
        1,
        (_) => List.generate(
          height,
          (j) => List.generate(
            width,
            (k) => List.generate(
              3,
              (l) => imageData[(j * width + k) * 3 + l],
            ),
          ),
        ),
      );

      // Run inference
      var output = List<List<num>>.generate(
          1, (_) => List.filled(2, 0.0, growable: false));

      _interpreter.run(input, output);

      // Apply Softmax to the output to get probabilities
      List<double> softmax(List<double> logits) {
        double maxLogit = logits.reduce((a, b) => a > b ? a : b); // Stability
        List<double> exps =
            logits.map((logit) => exp(logit - maxLogit)).toList();
        double sumExps = exps.reduce((a, b) => a + b);
        return exps.map((e) => e / sumExps).toList();
      }

      List<double> predictions = output[0].map((e) => e.toDouble()).toList();
      List<double> probabilities = softmax(predictions);

      // Find the class with the highest probability
      int predictedClass =
          probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

      this.predictedClass.value = predictedClass;

      // print(
      //     "Predicted class: $predictedClass with probabilities: $probabilities");

      return predictedClass; // Return the predicted class
    } catch (e) {
      print("Error processing image: $e");
      return -1; // Return error class
    }
  }

  // Function to get predicted class
  int getPredictedClass(List<dynamic> output) {
    int predictedClass = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    return predictedClass;
  }
}
