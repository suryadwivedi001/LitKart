import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:online_groceries/view/home/home_view.dart';
import 'package:online_groceries/common_widget/floating_cart_button.dart';

import '../../common/color_extension.dart';
import '../../view_model/favourite_view_model.dart';
import '../../view_model/cart_view_model.dart';
import '../account/account_view.dart';
import '../explore/explore_view.dart';
import '../favourite/favourite_view.dart';
import '../my_cart/my_cart_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int selectTab = 0;
  final favVM = Get.put(FavoriteViewModel());
  final cartVM = Get.put(CartViewModel()); // Keep this - it's the main instance

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    // CHANGE: 4 tabs instead of 5 (removed cart tab)
    controller = TabController(length: 4, vsync: this);
    controller?.addListener(() {
      selectTab = controller?.index ?? 0;

      // CHANGE: Updated index - Favourite is now index 2 (was 3)
      if(selectTab == 2) {
        favVM.serviceCalList();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    // Optionally delete CartViewModel here when the entire app section is disposed
    // Get.delete<CartViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // CHANGE: Remove MyCartView from TabBarView
          TabBarView(controller: controller, children: [
            const HomeView(),
            const ExploreView(),
            const FavoritesView(), // Moved up - now index 2
            const AccountView(),    // Moved up - now index 3
          ]),
          // FloatingCartButton that navigates directly to MyCartView
          FloatingCartButton(
            onTap: () {
              // Navigate directly to MyCartView instead of switching tabs
              Get.to(() => const MyCartView());
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, -2)
            )
          ]
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: TabBar(
              controller: controller,
              indicatorColor: Colors.transparent,
              indicatorWeight: 1,
              labelColor: TColor.primary,
              labelStyle: TextStyle(
                color: TColor.primary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              unselectedLabelColor: TColor.primaryText,
              unselectedLabelStyle: TextStyle(
                color: TColor.primaryText,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              // CHANGE: Removed Cart tab - only 4 tabs now
              tabs: [
                Tab(
                  text: "Shop",
                  icon: Image.asset(
                    "assets/img/store_tab.png",
                    width: 25,
                    height: 25,
                    color: selectTab == 0 ? TColor.primary : TColor.primaryText,
                  ),
                ),
                Tab(
                  text: "Explore",
                  icon: Image.asset(
                    "assets/img/explore_tab.png",
                    width: 25,
                    height: 25,
                    color: selectTab == 1 ? TColor.primary : TColor.primaryText,
                  ),
                ),
                // CART TAB REMOVED
                Tab(
                  text: "Favourite",
                  icon: Image.asset(
                    "assets/img/fav_tab.png",
                    width: 25,
                    height: 25,
                    color: selectTab == 2 ? TColor.primary : TColor.primaryText, // Changed from 3 to 2
                  ),
                ),
                Tab(
                  text: "Account",
                  icon: Image.asset(
                    "assets/img/account_tab.png",
                    width: 25,
                    height: 25,
                    color: selectTab == 3 ? TColor.primary : TColor.primaryText, // Changed from 4 to 3
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
