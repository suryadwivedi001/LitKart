import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common_widget/product_cell.dart';

import '../../common/color_extension.dart';
import '../../model/explore_category_model.dart';
import '../../view_model/cart_view_model.dart';
import '../../view_model/explore_item_view_model.dart';
import '../home/product_details_view.dart';
import 'filter_view.dart';
import 'package:online_groceries/common/globs.dart';


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
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double minCardWidth = 90;
          const int maxColumns = 3;
          const double horizontalGap = 8;
          const double gridHorizontalPadding = 8;

          final screenWidth = constraints.maxWidth;
          int columns = (screenWidth / (minCardWidth + horizontalGap)).floor();
          columns = columns.clamp(2, maxColumns);
          final totalGaps = (columns - 1) * horizontalGap;
          final cardWidth = ((screenWidth - 2 * gridHorizontalPadding) - totalGaps) / columns;

          return Obx(() => Padding(
                padding: EdgeInsets.symmetric(horizontal: gridHorizontalPadding),
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  itemCount: listVM.listArr.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: horizontalGap,
                    mainAxisSpacing: 9, // matches HomeView spacing
                    childAspectRatio: Globs.productCardAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    var pObj = listVM.listArr[index];
                    return ProductCell(
                      pObj: pObj,
                      margin: 0,
                      weight: cardWidth,
                      onPressed: () async {
                        await Get.to(() => ProductDetails(pObj: pObj));
                        listVM.serviceCallList();
                      },
                      onCart: () {
                        CartViewModel.serviceCallAddToCart(pObj.prodId ?? 0, 1, () {});
                      },
                    );
                  },
                ),
              ));
        },
      ),
    );
  }
}
