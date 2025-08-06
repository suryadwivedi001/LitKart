import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../common/color_extension.dart';
import '../../common_widget/product_cell.dart';
import '../../common_widget/custom_navigation_bar.dart';
import '../../common_widget/product_grid_view.dart'; // <-- import your reusable grid here
import '../../view_model/home_view_model.dart';
import 'product_details_view.dart';
import 'package:online_groceries/common/globs.dart';
import 'package:flutter/foundation.dart';
import '../../model/offer_product_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController txtSearch;
  final homeVM = Get.put(HomeViewModel());

  final RxList<String> dynamicSectionTabs = <String>[].obs;
  String selectedSection = "All";

  @override
  void initState() {
    super.initState();
    txtSearch = TextEditingController();
    homeVM.serviceCallHome();
    ever(homeVM.productList, (_) {
      _buildDynamicTabs();
    });
  }

  @override
  void dispose() {
    txtSearch.dispose();
    Get.delete<HomeViewModel>();
    super.dispose();
  }

  void _buildDynamicTabs() {
    final products = homeVM.productList;
    final uniqueTypes = products
        .map((p) => (p.typeName ?? '').trim())
        .where((name) => name.isNotEmpty)
        .map((name) => name.toLowerCase())
        .toSet()
        .toList();
    uniqueTypes.sort((a, b) => a.compareTo(b));
    List<String> tabs = ["All"];
    tabs.addAll(uniqueTypes.map((name) => _capitalize(name)));
    if (!listEquals(dynamicSectionTabs, tabs)) {
      dynamicSectionTabs.assignAll(tabs);
      if (!dynamicSectionTabs.contains(selectedSection)) {
        selectedSection = "All";
      }
      setState(() {});
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  List<OfferProductModel> getSectionProducts(String section) {
    final products = homeVM.productList.toList();
    if (section == "All") {
      return products;
    } else {
      return products
          .where((p) => (p.typeName?.toLowerCase() ?? '') == section.toLowerCase())
          .toList();
    }
  }

  String sectionToKey(String section) =>
      section.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "_");

  Future<bool> assetExists(String asset) async {
    try {
      await rootBundle.load(asset);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> sectionBgImagePath(String section) async {
    final pngPath = 'assets/img/${sectionToKey(section)}_bg.png';
    final jpgPath = 'assets/img/${sectionToKey(section)}_bg.jpg';
    try {
      await rootBundle.load(pngPath);
      return pngPath;
    } catch (_) {
      try {
        await rootBundle.load(jpgPath);
        return jpgPath;
      } catch (_) {
        return null;
      }
    }
  }

  Widget buildSectionTabBar() {
    return Obx(() {
      return SizedBox(
        height: 56,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: dynamicSectionTabs.length,
          itemBuilder: (context, index) {
            final section = dynamicSectionTabs[index];
            final isSelected = section == selectedSection;
            final assetKey = sectionToKey(section);
            final assetPath = 'assets/img/$assetKey.png';

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSection = section;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FutureBuilder<bool>(
                        future: assetExists(assetPath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.data == true) {
                            return Image.asset(
                              assetPath,
                              width: 16,
                              height: 16,
                              color: isSelected
                                  ? TColor.primary
                                  : TColor.primaryText.withOpacity(0.68),
                            );
                          } else {
                            return Icon(
                              Icons.layers_outlined,
                              size: 16,
                              color: isSelected
                                  ? TColor.primary
                                  : TColor.primaryText.withOpacity(0.42),
                            );
                          }
                        }),
                    const SizedBox(height: 5),
                    Text(
                      section,
                      style: TextStyle(
                        fontSize: 11.3,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        color: isSelected
                            ? TColor.primary
                            : TColor.primaryText.withOpacity(0.67),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 190),
                      margin: const EdgeInsets.only(top: 3),
                      height: 2.5,
                      width: isSelected ? 22 : 0,
                      decoration: BoxDecoration(
                        color: isSelected ? TColor.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Single background image, covers upper half for everything behind navigation/search
            FutureBuilder<String?>(
              future: sectionBgImagePath(selectedSection),
              builder: (context, snapshot) {
                final bgPath = snapshot.data;
                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.60,
                      width: double.infinity,
                      child: bgPath != null
                          ? Image.asset(
                              bgPath,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.white),
                    ),
                    Expanded(child: Container(color: Colors.white)),
                  ],
                );
              },
            ),

            // Foreground UI layer—everything transparent/overlay on top of single background image
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CustomNavigationBar should now be transparent (no bg color)
                const CustomNavigationBar(),

                const SizedBox(height: 6),

                // Search bar with slight transparent white background for legibility
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 47,
                      color: Colors.white.withOpacity(0.15),
                      child: TextField(
                        controller: txtSearch,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              "assets/img/search.png",
                              width: 18,
                              height: 18,
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
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                buildSectionTabBar(),

                Expanded(
                  child: Obx(() {
                    final items = getSectionProducts(selectedSection);
                    return ProductGridView(
                      products: items,
                      minCardWidth: 90,
                      maxColumns: 3,
                      horizontalGap: 8,
                      gridHorizontalPadding: 8,
                      childAspectRatio: Globs.productCardAspectRatio,
                      emptyMessage: "No products available in this section.",
                      onProductTap: (product) async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            final halfScreenHeight = MediaQuery.of(context).size.height * 0.7;
                            return SizedBox(
                              height: halfScreenHeight,
                              child: ProductDetails(
                                pObj: product,
                                asModalSheet: true,
                              ),
                            );
                          },
                        );
                        homeVM.serviceCallHome();
                      },
                      onCart: (product) {},
                      scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: false,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
