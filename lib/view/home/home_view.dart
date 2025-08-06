import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../common/color_extension.dart';
import '../../common_widget/product_cell.dart';
import '../../common_widget/custom_navigation_bar.dart';
import '../../common_widget/product_grid_view.dart';  // <-- import your reusable grid here
import '../../view_model/home_view_model.dart';
import 'product_details_view.dart'; // <- corrected if your file name is product_details.dart
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

  // Reactive dynamic tabs list
  final RxList<String> dynamicSectionTabs = <String>[].obs;

  // Currently selected tab
  String selectedSection = "All";

  @override
  void initState() {
    super.initState();
    txtSearch = TextEditingController();

    // Call API and then build tabs dynamically when product list updates
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

    // Extract unique, non-null, non-empty type names (case insensitive)
    final uniqueTypes = products
        .map((p) => (p.typeName ?? '').trim())
        .where((name) => name.isNotEmpty)
        .map((name) => name.toLowerCase())
        .toSet()
        .toList();

    // Sort alphabetically (case insensitive)
    uniqueTypes.sort((a, b) => a.compareTo(b));

    // Build tab names with formatted casing
    List<String> tabs = ["All"];
    tabs.addAll(uniqueTypes.map((name) => _capitalize(name)));

    // Update reactive tab list, avoid redundant assignment to improve performance
    if (!listEquals(dynamicSectionTabs, tabs)) {
      dynamicSectionTabs.assignAll(tabs);
      // Optional: reset selectedSection when tabs change and "All" tab is always present
      if (!dynamicSectionTabs.contains(selectedSection)) {
        selectedSection = "All"; // reset to All if previous selection is invalid
      }
      setState(() {}); // rebuild tab bar
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  // Filtering products based on selectedSection
  List <OfferProductModel> getSectionProducts(String section) {
    final products = homeVM.productList.toList();

    if (section == "All") {
      // Show all products (including those without typeName)
      return products;
    } else {
      // Filter by matching type name case-insensitive
      return products.where((p) =>
          (p.typeName?.toLowerCase() ?? '') == section.toLowerCase()).toList();
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
            // BACKGROUND layer (covers upper half according to section, else white)
            FutureBuilder<String?>(
              future: sectionBgImagePath(selectedSection),
              builder: (context, snapshot) {
                final bgPath = snapshot.data;
                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
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
            // FOREGROUND layer (all functional UI remains)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              Image.asset("assets/img/color_logo.png", width: 25),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/img/location.png", width: 16, height: 16),
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
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    height: 47,
                    decoration: BoxDecoration(
                      color: const Color(0xffF2F3F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
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
                        // Optional: implement search filter logic here if needed
                        setState(() {});
                      },
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
                            height: halfScreenHeight, // Limit height to half screen
                            child: ProductDetails(
                              pObj: product,
                              asModalSheet: true, // Show as modal sheet
                            ),
                          );
                        },
                      );
                        homeVM.serviceCallHome(); // Refresh after modal closes, as you already do
                      },
                      onCart: (product) {
                        // No-op, as before; add cart logic here if needed
                      },
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
