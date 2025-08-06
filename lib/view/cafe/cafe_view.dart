import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common_widget/product_grid_view.dart'; // shared widget
import '../../model/offer_product_model.dart';       // model
import '../../view_model/cafe_view_model.dart';      // view model
import '../home/product_details_view.dart';          // details page

class CafeView extends StatelessWidget {
  final CafeViewModel cafeVM = Get.put(CafeViewModel());

  CafeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafe'),
      ),
      body: Obx(() {
        // Use the getter 'filteredCafeItems' instead of a nonexistent method
        final List<OfferProductModel> items = cafeVM.filteredCafeItems;

        return ProductGridView(
          products: items,
          onProductTap: (product) async {
            // Use parameter name 'product' as in ProductDetailsView constructor
            await Get.to(() => ProductDetails(pObj: product));
            cafeVM.refreshCafeList();  // Call the refresh method instead of loadCafeList
          },
          // Call the correct add-to-cart method name
          onCart: (product) => cafeVM.addItemToCart(product),

          emptyMessage: "No Cafe items available.",
          // Customize other params if needed
        );
      }),
    );
  }
}
