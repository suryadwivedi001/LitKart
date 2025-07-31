import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common/globs.dart';
import 'package:online_groceries/common/service_call.dart';

import '../model/offer_product_model.dart'; // assuming this can map your unified product model
import '../model/type_model.dart';

class HomeViewModel extends GetxController {
  // Single unified list of products from 'product_list' API key
  final RxList<OfferProductModel> productList = <OfferProductModel>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) print("HomeViewModel Init");
    serviceCallHome();
  }

  void serviceCallHome() {
    Globs.showHUD();
    ServiceCall.post({}, SVKey.svHome, isToken: true, withSuccess: (resObj) async {
      print("✅ Home API Success: $resObj");
      Globs.hideHUD();

      if (resObj[KKey.status] == "1") {
        var payload = resObj[KKey.payload] as Map? ?? {};

        var productDataArr = (payload["product_list"] as List? ?? []).map((oObj) {
          if (kDebugMode) print("🔥 Product Raw: $oObj");
          return OfferProductModel.fromJson(oObj);
        }).toList();

        productList.value = productDataArr;
      } else {
        // You can handle error case here, e.g. clear list
        productList.clear();
      }
    }, failure: (err) async {
      Globs.hideHUD();
      Get.snackbar(Globs.appName, err.toString());
    });
  }
}
