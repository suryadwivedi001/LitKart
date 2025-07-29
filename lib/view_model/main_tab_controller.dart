import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainTabController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final selectTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      selectTab.value = tabController.index;
    });
  }

  void animateTo(int index) {
    tabController.animateTo(index);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
