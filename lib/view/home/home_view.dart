import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/color_extension.dart';
import '../../common_widget/product_cell.dart';
import '../../common_widget/custom_navigation_bar.dart';
import '../../view_model/home_view_model.dart';
import 'product_details_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController txtSearch;
  final homeVM = Get.put(HomeViewModel());

  // Section/tabs to display—add/remove as needed
  final List<String> sectionTabs = [
    "All",
    "Exclusive Offer",
    "Best Selling",
    "Groceries",
    "Rakhi",
    "Electronics",
    "Beauty",
    "Snacks",
    "Shakes",
    "Juices",
    "Printing",
    "Forgettables",
  ];

  String selectedSection = "All";

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

  /// Returns OfferProductModel items for selected tab.
  /// You can expand this to fetch sectioned data as your project grows.
  List getSectionProducts(String section) {
    switch (section) {
      case 'Exclusive Offer':
        return homeVM.offerArr;
      case 'Best Selling':
        return homeVM.bestSellingArr;
      case 'Groceries':
        return homeVM.listArr;
      // Sections with no data yet—later you can wire new lists in HomeViewModel
      case 'Rakhi':
      case 'Electronics':
      case 'Beauty':
      case 'Snacks':
      case 'Shakes':
      case 'Juices':
      case 'Printing':
      case 'Forgettables':
        return [];
      case 'All':
      default:
        return [
          ...homeVM.offerArr,
          ...homeVM.bestSellingArr,
          ...homeVM.listArr,
        ];
    }
  }

  /// Top section/tabs nav as a horizontally scrollable bar.
  Widget buildSectionTabBar() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: sectionTabs.length,
        itemBuilder: (context, index) {
          final section = sectionTabs[index];
          final isSelected = section == selectedSection;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => setState(() => selectedSection = section),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? TColor.primary.withOpacity(0.12) : TColor.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? TColor.primary : TColor.placeholder.withOpacity(0.16),
                    width: isSelected ? 1.1 : 0.7,
                  ),
                ),
                child: Text(
                  section,
                  style: TextStyle(
                    color: isSelected ? TColor.primary : TColor.primaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Product grid for active section: shows your finalized ProductCell (width 90),
  /// three per row, vertical scroll, minimal left/right padding.
  Widget buildVerticalProductGrid(List items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 36),
        child: Center(
          child: Text(
            "No products available in this section.",
            style: TextStyle(color: TColor.secondaryText),
          ),
        ),
      );
    }
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Minimal app-wide left/right padding
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,        // 3 product cards per row
        crossAxisSpacing: 2,      // space between columns
        mainAxisSpacing: 7,       // space between rows
        childAspectRatio: 0.4,   // (width/height), tweak for look as needed
      ),
      itemBuilder: (context, index) {
        final pObj = items[index];
        return ProductCell(
          pObj: pObj,
          margin: 0.7,    // Card-to-card horizontal margin inside each grid cell
          onPressed: () async {
            await Get.to(() => ProductDetails(pObj: pObj));
            homeVM.serviceCallHome();
          },
          onCart: () {},
          weight: 86,     // Fixes card width for 3 per row, matches your ProductCell
        );
      },
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
            // Nav bar/header (unchanged)
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
            // Search Bar
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
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Section TabBar
            buildSectionTabBar(),
            // The banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xffF2F3F2),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/banner_top.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Product Grid for Active Section
            Expanded(
              child: Obx(() {
                final items = getSectionProducts(selectedSection);
                return SingleChildScrollView(
                  child: buildVerticalProductGrid(items),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
