import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/view/home/product_details_view.dart';

import '../../common/color_extension.dart';
import '../../common_widget/category_cell.dart';
import '../../common_widget/product_cell.dart';
import '../../common_widget/section_view.dart';
import '../../common_widget/custom_navigation_bar.dart';
import '../../view_model/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController txtSearch;
  final homeVM = Get.put(HomeViewModel());

  @override
  void initState() {
    super.initState();
    txtSearch = TextEditingController();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    Get.delete<HomeViewModel>();
    super.dispose();
  }

  // Horizontal card list
  Widget buildProductHorizontalList(List items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 245, // Set height for vertical cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final pObj = items[index];
          return ProductCell(
            pObj: pObj,
            margin: 7, // Smaller margin for packed look
            onPressed: () async {
              await Get.to(() => ProductDetails(pObj: pObj));
              homeVM.serviceCallHome();
            },
            onCart: () {}, // For compatibility
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation Bar with fallback
            Builder(
              builder: (_) {
                try {
                  return const CustomNavigationBar();
                } catch (_) {
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
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
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      onPressed: () {},
                    ),
                    Obx(() => buildProductHorizontalList(homeVM.offerArr)),
                    // Best Selling Section
                    SectionView(
                      title: "Best Selling",
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      onPressed: () {},
                    ),
                    Obx(() => buildProductHorizontalList(homeVM.bestSellingArr)),
                    // Groceries Section - Horizontal categories
                    SectionView(
                      title: "Groceries",
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                            final pObj = homeVM.groceriesArr[index];
                            return CategoryCell(
                              pObj: pObj,
                              onPressed: () {},
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // More products (optional)
                    Obx(() => buildProductHorizontalList(homeVM.listArr)),
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
