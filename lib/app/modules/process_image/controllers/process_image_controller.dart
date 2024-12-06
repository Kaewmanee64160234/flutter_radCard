import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_card/app/data/models/card_type.dart';
import 'package:read_card/app/data/services/api_image_preprocessing_service.dart';
import 'package:read_card/app/data/services/api_ocr_credit_card_service.dart';

class ProcessImageController extends GetxController {
  final ApiImagePreprocessingService imageProcessingService = Get.find();
  final ApiOcrCreditCardService apiOcrCreditCardService = Get.find();

  final RxBool isLoading = false.obs; // Loading state
  final RxString processedImageBase64 = RxString('');
  final Rx<File?> selectedImage = Rx<File?>(null);
  final Rx<ID_CARD> card = ID_CARD(
    idNumber: '',
    th: ID_CARD_DETAIL(
      fullName: '',
      prefix: '',
      name: '',
      lastName: '',
      dateOfBirth: '',
      dateOfIssue: '',
      dateOfExpiry: '',
      religion: '',
      address: Address(
        province: '',
        district: '',
        full: '',
        firstPart: '',
        subdistrict: '',
      ),
    ),
    en: ID_CARD_DETAIL(
      fullName: '',
      prefix: '',
      name: '',
      lastName: '',
      dateOfBirth: '',
      dateOfIssue: '',
      dateOfExpiry: '',
      religion: '',
      address: Address(
        province: '',
        district: '',
        full: '',
        firstPart: '',
        subdistrict: '',
      ),
    ),
    portrait: '',
  ).obs;

  Future<void> pickAndProcessImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);

        processedImageBase64.value =
            await imageProcessingService.preprocessImage(pickedFile.path);
      } else {
        Get.snackbar("Error", "No image selected.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to process the image: $e");
    }
  }

  Future<void> sendToOcr() async {
    try {
      isLoading.value = true; // Show loading spinner

      // Check if the processed Base64 image is available
      if (processedImageBase64.value.isNotEmpty) {
        // Decode Base64 string into bytes
        final processedBytes = base64Decode(processedImageBase64.value);

        // Create a temporary file to store the processed image
        final Directory tempDir = Directory.systemTemp;
        final File processedImage = File('${tempDir.path}/processed_image.jpg');
        await processedImage.writeAsBytes(processedBytes);

        // Send the file to the OCR API
        final card_ = await apiOcrCreditCardService.uploadFile(processedImage);
        card.value = card_;

        // Log the successful result
        print('Card details: ${card.value.idNumber}');
      } else {
        Get.snackbar("Error", "No processed image found.");
      }
    } catch (e) {
      // Handle and log errors
      Get.snackbar("Error", "Failed to send image to OCR: $e");
      print("Error in sendToOcr: $e");
    } finally {
      // Hide loading spinner regardless of success or error
      isLoading.value = false;
    }
  }
}
