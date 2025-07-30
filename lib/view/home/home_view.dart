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

  // Section/tabs
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

  // Maps section -> product list
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

  Widget buildSectionTabBar() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: sectionTabs.length,
        itemBuilder: (context, index) {
          final section = sectionTabs[index];
          final isSelected = section == selectedSection;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => selectedSection = section),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? TColor.primary.withOpacity(0.11) : TColor.white,
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

  Widget buildHorizontalProductTray(List items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Text(
            "No products available in this section.",
            style: TextStyle(color: TColor.secondaryText),
          ),
        ),
      );
    }
    return SizedBox(
      height: 255, // controls vertical size of card tray (should fit ProductCell)
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final pObj = items[index];
          return ProductCell(
            pObj: pObj,
            margin: 7,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation bar/header
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
            const SizedBox(height: 13),

            // Section TabBar
            buildSectionTabBar(),

            // The banner, then the horizontal tray for the selected section
            Expanded(
              child: Obx(() {
                final items = getSectionProducts(selectedSection);
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      buildHorizontalProductTray(items),
                    ],
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
