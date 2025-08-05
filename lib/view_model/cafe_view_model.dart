import 'package:get/get.dart';
import 'package:online_groceries/model/offer_product_model.dart';
import 'package:online_groceries/view_model/home_view_model.dart';

class CafeViewModel extends GetxController {
  final RxList<OfferProductModel> cafeList = <OfferProductModel>[].obs;

  // keep for UI visual toggling only
  final RxBool showVeg = true.obs;
  final RxBool showNonVeg = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCafeList();

    final homeVM = Get.find<HomeViewModel>();
    ever(homeVM.productList, (_) => loadCafeList());
  }

  void loadCafeList() {
    final homeVM = Get.find<HomeViewModel>();
    cafeList.assignAll((homeVM.productList).where((p) {
      final t = (p.typeName ?? "").toLowerCase();
      return t == "food" || t == "beverages";
    }));
  }

  void toggleVeg() => showVeg.value = !showVeg.value;
  void toggleNonVeg() => showNonVeg.value = !showNonVeg.value;
}
