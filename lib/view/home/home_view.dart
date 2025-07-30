import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/color_extension.dart';
import '../../common_widget/product_cell.dart';
import '../../common_widget/custom_navigation_bar.dart';
import 'package:flutter/services.dart';
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

  // Section/tabs for the top
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
  List getSectionProducts(String section) {
    switch (section) {
      case 'Exclusive Offer':
        return homeVM.offerArr;
      case 'Best Selling':
        return homeVM.bestSellingArr;
      case 'Groceries':
        return homeVM.listArr;
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

  /// The responsive grid.
  Widget buildResponsiveProductGrid(List items, BoxConstraints constraints) {
    // Base settings for card and gap
    const double minCardWidth = 90;
    const int maxColumns = 3;
    const double horizontalGap = 8;
    const double gridHorizontalPadding = 8;

    // Calculate how many cards per row, and card width, dynamically
    final screenWidth = constraints.maxWidth;
    int columns = (screenWidth / (minCardWidth + horizontalGap)).floor();
    columns = columns.clamp(2, maxColumns);

    double totalGaps = (columns - 1) * horizontalGap;
    double cardWidth = ((screenWidth - 2 * gridHorizontalPadding) - totalGaps) / columns;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            "No products available in this section.",
            style: TextStyle(color: TColor.secondaryText),
          ),
        ),
      );
    }

    // Most typical aspect ratios of your card are between 0.55-0.67
    final double aspectRatio = cardWidth / 260;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gridHorizontalPadding),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: horizontalGap,
          mainAxisSpacing: 9,
          childAspectRatio: aspectRatio,
        ),
        itemBuilder: (context, index) {
          final pObj = items[index];
          return ProductCell(
            pObj: pObj,
            margin: 0,      // grid handles spacing
            weight: cardWidth,
            onPressed: () async {
              await Get.to(() => ProductDetails(pObj: pObj));
              homeVM.serviceCallHome();
            },
            onCart: () {},
          );
        },
      ),
    );
  }

  // Section tabs bar
Widget buildSectionTabBar() {
  return SizedBox(
    height: 56,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: sectionTabs.length,
      itemBuilder: (context, index) {
        final section = sectionTabs[index];
        final isSelected = section == selectedSection;
        final assetKey = section.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "_");
        final assetPath = 'assets/img/$assetKey.png';

        return GestureDetector(
          onTap: () => setState(() => selectedSection = section),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8), // compact horizontal spacing
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // The icon (small, no circle, no border!)
                FutureBuilder<bool>(
                  future: assetExists(assetPath),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                      return Image.asset(
                        assetPath,
                        width: 16,
                        height: 16,
                        color: isSelected ? TColor.primary : TColor.primaryText.withOpacity(0.68),
                      );
                    } else {
                      // Simple small box or blank as placeholder
                      return Icon(Icons.layers_outlined, 
                        size: 16, 
                        color: isSelected ? TColor.primary : TColor.primaryText.withOpacity(0.40),
                      );
                    }
                  }
                ),
                const SizedBox(height: 5),
                // Label: very small font, no bold, all caps for "tray" feeling
                Text(
                  section,
                  style: TextStyle(
                    fontSize: 11.3,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: isSelected ? TColor.primary : TColor.primaryText.withOpacity(0.67),
                    // Try to uppercase for clear tabs, or as per your preference
                  ),
                ),
                // Highlight underline/rect for selected
                AnimatedContainer(
                  duration: const Duration(milliseconds: 190),
                  margin: const EdgeInsets.only(top: 3),
                  height: 2.5,
                  width: isSelected ? 22 : 0,
                  decoration: BoxDecoration(
                    color: isSelected ? TColor.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Checks if an asset exists (shows icon if so, else placeholder)
Future<bool> assetExists(String asset) async {
  try {
    await rootBundle.load(asset);
    return true;
  } catch (_) {
    return false;
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar/header (unchanged)
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
            buildSectionTabBar(),
            // Banner Responsive product grid for active section
            Expanded(
              child: Obx(() {
                final items = getSectionProducts(selectedSection);
                return LayoutBuilder(
                  builder: (context, constraints) =>
                    SingleChildScrollView(
                      child: buildResponsiveProductGrid(items, constraints),
                    ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
