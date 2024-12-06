import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_card/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.PROCESS_IMAGE);
              },
              child: const Text("Go to Target Page"),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.CAMERA_DETECT);
              },
              child: const Text("Go to Camera Page"),
            ),
          ],
        ),
      ),
    );
  }
}
