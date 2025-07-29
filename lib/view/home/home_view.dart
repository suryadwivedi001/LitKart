import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/view/home/product_details_view.dart';

import '../../common/color_extension.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/product_cell.dart';
import '../../common_widget/section_view.dart';
import '../../common_widget/custom_navigation_bar.dart';
import '../../view_model/cart_view_model.dart';
import '../../view_model/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController txtSearch = TextEditingController();
  final homeVM = Get.put(HomeViewModel());

  // The product grid builder remains unchanged
  Widget buildProductGrid(List items) {
    if (items.isEmpty) return const SizedBox.shrink();

    if (items.length <= 3) {
      // Single-row horizontal list for ≤3 products
      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var pObj = items[index];
            return ProductCell(
              pObj: pObj,
              weight: 140,
              margin: 6,
              onPressed: () async {
                await Get.to(() => ProductDetails(pObj: pObj));
                homeVM.serviceCallHome();
              },
            );
          },
        ),
      );
    } else {
      // 2-row vertical grid for 4+ products
      int itemsPerColumn = 2;
      int columns = (items.length / itemsPerColumn).ceil();

      return SizedBox(
        height: 340,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: columns,
          itemBuilder: (context, colIndex) {
            final firstIndex = colIndex * itemsPerColumn;
            final secondIndex = firstIndex + 1;
            return Container(
              width: 140,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProductCell(
                    pObj: items[firstIndex],
                    weight: 140,
                    margin: 0,
                    onPressed: () async {
                      await Get.to(() => ProductDetails(pObj: items[firstIndex]));
                      homeVM.serviceCallHome();
                    },
                  ),
                  if (secondIndex < items.length) ...[
                    const SizedBox(height: 8),
                    ProductCell(
                      pObj: items[secondIndex],
                      weight: 140,
                      margin: 0,
                      onPressed: () async {
                        await Get.to(() => ProductDetails(pObj: items[secondIndex]));
                        homeVM.serviceCallHome();
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    Get.delete<HomeViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: Top bars (address, search) are out of scroll view
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Bar
            Builder(
              builder: (context) {
                try {
                  return CustomNavigationBar();
                } catch (e) {
                  // Fallback (in rare case nav bar fails)
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/img/color_logo.png",
                            width: 25,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/img/location.png",
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Dhaka, Banassre",
                            style: TextStyle(
                              color: TColor.darkGray,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xffF2F3F2),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: txtSearch,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Image.asset(
                        "assets/img/search.png",
                        width: 20,
                        height: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Search Store",
                    hintStyle: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.maxFinite,
                        height: 115,
                        decoration: BoxDecoration(
                          color: const Color(0xffF2F3F2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/img/banner_top.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Exclusive Offer Section
                    SectionView(
                      title: "Exclusive Offer",
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      onPressed: () {},
                    ),
                    Obx(() => buildProductGrid(homeVM.offerArr)),
                    // Best Selling Section
                    SectionView(
                      title: "Best Selling",
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      onPressed: () {},
                    ),
                    Obx(() => buildProductGrid(homeVM.bestSellingArr)),
                    // Groceries Section (icons row)
                    SectionView(
                      title: "Groceries",
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      onPressed: () {},
                    ),
                    SizedBox(
                      height: 100,
                      child: Obx(
                        () => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: homeVM.groceriesArr.length,
                          itemBuilder: (context, index) {
                            var pObj = homeVM.groceriesArr[index];
                            return CategoryCell(
                              pObj: pObj,
                              onPressed: () {},
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Additional Products Section
                    Obx(() => buildProductGrid(homeVM.listArr)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
