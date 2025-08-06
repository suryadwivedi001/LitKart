import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common_widget/product_grid_view.dart';
import 'package:online_groceries/model/offer_product_model.dart';

import '../../common/color_extension.dart';
import '../../model/explore_category_model.dart';
import '../../view_model/cart_view_model.dart';
import '../../view_model/explore_item_view_model.dart';
import 'filter_view.dart';
import 'package:online_groceries/common/globs.dart';
import '../../view/home/product_details_view.dart';

class ExploreDetailView extends StatefulWidget {
  final ExploreCategoryModel eObj;
  const ExploreDetailView({super.key, required this.eObj});

  @override
  State<ExploreDetailView> createState() => _ExploreDetailViewState();
}

class _ExploreDetailViewState extends State<ExploreDetailView> {
  late ExploreItemViewMode listVM;

  @override
  void initState() {
    super.initState();
    listVM = Get.put(ExploreItemViewMode(widget.eObj));
  }

  @override
  void dispose() {
    Get.delete<ExploreItemViewMode>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image.asset(
            "assets/img/back.png",
            width: 20,
            height: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FilterView(),
                ),
              );
            },
            icon: Image.asset(
              "assets/img/filter_ic.png",
              width: 20,
              height: 20,
            ),
          ),
        ],
        title: Text(
          widget.eObj.catName ?? "",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Obx(() {
        final items = listVM.listArr;

        return ProductGridView(
          products: items,
          minCardWidth: 90,
          maxColumns: 3,
          horizontalGap: 8,
          gridHorizontalPadding: 8,
          childAspectRatio: Globs.productCardAspectRatio,
          emptyMessage: "No items available in this category.",
          onProductTap: (product) async {
            await Get.to(() => ProductDetails(pObj: product));
            listVM.serviceCallList();
          },
          onCart: (product) {
            CartViewModel.serviceCallAddToCart(product.prodId ?? 0, 1, () {});
          },
        );
      }),
    );
  }
}
