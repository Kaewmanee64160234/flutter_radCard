import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/process_image_controller.dart';

class ProcessImageView extends GetView<ProcessImageController> {
  const ProcessImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Image'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Column(
                  children: [
                    // Display the original image
                    Obx(() {
                      if (controller.selectedImage.value != null) {
                        return Image.file(
                          controller.selectedImage.value!,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        );
                      }
                      return const Text('No image selected.');
                    }),
                    const SizedBox(height: 20),
                    // Display the processed image
                    Obx(() {
                      if (controller.processedImageBase64.value.isNotEmpty) {
                        final processedBytes =
                            base64Decode(controller.processedImageBase64.value);
                        return Image.memory(
                          processedBytes,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        );
                      }
                      return const Text('Processed image will appear here.');
                    }),
                  ],
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.pickAndProcessImage,
                child: const Text('Pick and Process Image'),
              ),
              ElevatedButton(
                onPressed: controller.sendToOcr,
                child: const Text('Process to OCR'),
              ),
              Obx(() {
                if (controller.card.value.idNumber.isNotEmpty) {
                  return Column(
                    children: [
                      // show image from base 64 profile
                      Image.memory(
                        base64Decode(controller.card.value.portrait),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      Text('Card ID: ${controller.card.value.idNumber}'),
                      Text('Full Name: ${controller.card.value.th.fullName}'),
                      Text(
                          'Date of Birth: ${controller.card.value.th.dateOfBirth}'),
                      Text(
                          'Date of Issue: ${controller.card.value.th.dateOfIssue}'),
                      Text(
                          'Date of Expiry: ${controller.card.value.th.dateOfExpiry}'),
                      Text('Address: ${controller.card.value.th.address.full}'),
                    ],
                  );
                }
                return const Text('Card details will appear here.');
              }),
            ],
          ),
        ),
      ),
    );
  }
}
