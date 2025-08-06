import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common_widget/product_grid_view.dart';
import '../../model/offer_product_model.dart';
import '../../view_model/cafe_view_model.dart';
import '../home/product_details_view.dart';
import '../../common_widget/custom_navigation_bar.dart'; // Update path if needed

class CafeView extends StatelessWidget {
  final CafeViewModel cafeVM = Get.put(CafeViewModel());

  CafeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),           // Height of nav bar
              const SizedBox(height: 60),           // Comfortable extra spacing below nav bar
              Expanded(
                child: Obx(() {
                  final List<OfferProductModel> items = cafeVM.filteredCafeItems;
                  return ProductGridView(
                    products: items,
                    onProductTap: (product) async {
                      await Get.to(() => ProductDetails(pObj: product));
                      cafeVM.refreshCafeList();
                    },
                    onCart: (product) => cafeVM.addItemToCart(product),
                    emptyMessage: "No Cafe items available.",
                  );
                }),
              ),
            ],
          ),
          // Floating navigation bar at top
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavigationBar(),
          ),
        ],
      ),
    );
  }
}
