import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:online_groceries/view/home/home_view.dart';
import 'package:online_groceries/common_widget/floating_cart_button.dart';

import '../../common/color_extension.dart';
import '../../view_model/favourite_view_model.dart';
import '../../view_model/cart_view_model.dart';
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
  final cartVM = Get.put(CartViewModel());

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    
    // IMPORTANT: Change length from 4 to 3 tabs
    controller = TabController(length: 3, vsync: this);

    controller?.addListener(() {
      selectTab = controller?.index ?? 0;

      // The "Favourite" tab index is now 2 (last tab)
      if (selectTab == 2) {
        favVM.serviceCalList();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // IMPORTANT: remove AccountView from children
          TabBarView(controller: controller, children: [
            const HomeView(),
            const ExploreView(),
            const FavoritesView(),
          ]),

          // Show floating cart button only when NOT on the last tab (Favourite) - adjust here
          if (selectTab != 2)
            FloatingCartButton(
              onTap: () {
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
                  offset: Offset(0, -2))
            ]),
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
            // IMPORTANT: Remove the Account tab entirely here
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
              Tab(
                text: "Favourite",
                icon: Image.asset(
                  "assets/img/fav_tab.png",
                  width: 25,
                  height: 25,
                  color: selectTab == 2 ? TColor.primary : TColor.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
