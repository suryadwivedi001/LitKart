import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/color_extension.dart';
import '../../common_widget/explore_cell.dart';
import '../../view_model/explore_view_model.dart';
import 'explore_detail_view.dart';
import '../../common_widget/custom_navigation_bar.dart'; // Make sure this path is correct

/// ExploreView shows a grid of products with comfortable top spacing.
class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final exploreVM = Get.put(ExploreViewModel());

  @override
  void dispose() {
    Get.delete<ExploreViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content with spacing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // for nav bar
              const SizedBox(height: 100), // comfortable additional spacing
              Expanded(
                child: Obx(
                  () => GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: exploreVM.listArr.length,
                    itemBuilder: (context, index) {
                      var eObj = exploreVM.listArr[index];
                      return ExploreCell(
                        pObj: eObj,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExploreDetailView(eObj: eObj),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Floating nav bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavigationBar(),
          ),
        ],
      ),
    );
  }
}
