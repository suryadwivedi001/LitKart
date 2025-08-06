import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common_widget/product_grid_view.dart';
import '../../common/color_extension.dart';
import '../../model/explore_category_model.dart';
import '../../model/offer_product_model.dart'; // Ensure this import is here
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
          onPressed: () => Navigator.pop(context),
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
                MaterialPageRoute(builder: (context) => const FilterView()),
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
        // Access the list reactively
        final List<OfferProductModel> items = listVM.listArr.toList();

        return ProductGridView(
          products: items,
          minCardWidth: 90,
          maxColumns: 3,
          horizontalGap: 8,
          gridHorizontalPadding: 16,  // Adjust side padding as desired
          childAspectRatio: Globs.productCardAspectRatio,
          mainAxisSpacing: 20,          // Vertical spacing between grid rows
          emptyMessage: "No items available in this category.",
          onProductTap: (product) async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                final trayHeight = MediaQuery.of(context).size.height * 0.7;
                return SizedBox(
                  height: trayHeight,
                  child: ProductDetails(
                    pObj: product,
                    asModalSheet: true,
                  ),
                );
              },
            );
            listVM.serviceCallList(); // Refresh list if needed after closing modal
          },
          onCart: (product) {
            CartViewModel.serviceCallAddToCart(product.prodId ?? 0, 1, () {});
          },
        );
      }),
    );
  }
}
