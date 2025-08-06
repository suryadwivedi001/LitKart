import 'package:get/get.dart';
import 'package:online_groceries/model/offer_product_model.dart';
import 'package:online_groceries/view_model/home_view_model.dart';

class CafeViewModel extends GetxController {
  final RxList<OfferProductModel> cafeList = <OfferProductModel>[].obs;

  // UI visual toggling only
  final RxBool showVeg = true.obs;
  final RxBool showNonVeg = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCafeList();

    final homeVM = Get.find<HomeViewModel>();
    ever(homeVM.productList, (_) => loadCafeList());
  }

  /// Loads cafe list items from HomeViewModel's product list,
  /// filtered by typeName == "food" or "beverages"
  void loadCafeList() {
    final homeVM = Get.find<HomeViewModel>();
    cafeList.assignAll(
      homeVM.productList.where((p) {
        final t = (p.typeName ?? "").toLowerCase();
        return t == "food" || t == "beverages";
      }),
    );
  }

  /// Returns the filtered list based on veg/non-veg toggles
  List<OfferProductModel> get filteredCafeItems {
    return cafeList.where((p) {
      final isVeg = (p.isVeg ?? false);
      if (isVeg && showVeg.value) return true;
      if (!isVeg && showNonVeg.value) return true;
      return false;
    }).toList();
  }

  /// Toggle vegetarian filter
  void toggleVeg() => showVeg.value = !showVeg.value;

  /// Toggle non-vegetarian filter
  void toggleNonVeg() => showNonVeg.value = !showNonVeg.value;

  /// Stub method for adding an item to cart — implement your business logic here
  void addItemToCart(OfferProductModel product) {
    // TODO: Add your cart addition logic here
    print("Adding product to cart: ${product.name}");
  }

  /// Refresh the cafe list (reload and notify observers)
  void refreshCafeList() {
    loadCafeList();
    // Notify listeners, if needed (Obx listens on cafeList)
    cafeList.refresh();
  }
}
