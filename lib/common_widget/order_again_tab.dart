import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/color_extension.dart';
import '../common/globs.dart';
import '../model/offer_product_model.dart';
import '../common_widget/product_grid_view.dart';
import '../view/home/product_details_view.dart';
import '../view_model/cart_view_model.dart';
import '../view_model/splash_view_model.dart';
import '../common_widget/floating_cart_button.dart';
import '../common_widget/custom_navigation_bar.dart'; // Update the path if needed

class OrderAgainTab extends StatefulWidget {
  const OrderAgainTab({super.key});

  @override
  State<OrderAgainTab> createState() => _OrderAgainTabState();
}

class _OrderAgainTabState extends State<OrderAgainTab> {
  final RxList<OfferProductModel> productList = <OfferProductModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = "".obs;

  final CartViewModel cartVM = Get.find<CartViewModel>();
  late final SplashViewModel splashVM;

  @override
  void initState() {
    super.initState();
    splashVM = Get.find<SplashViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchPreviouslyOrderedProducts());
  }

  Future<void> fetchPreviouslyOrderedProducts() async {
    try {
      Globs.showHUD(status: "Loading...");

      String authToken = splashVM.userPayload.value.authToken ?? "";
      if (authToken.isEmpty) {
        errorMessage.value = "Please log in to view previously ordered products.";
        productList.clear();
        isLoading.value = false;
        Globs.hideHUD();
        return;
      }

      final url = SVKey.svOrderAgain;
      final response = await GetConnect().post(
        url,
        {},
        headers: {"access_token": authToken},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = response.body;
        if (body["status"] == "1" &&
            body["payload"] != null &&
            body["payload"]["product_list"] != null) {
          productList.assignAll(
            (body["payload"]["product_list"] as List)
                .map((j) => OfferProductModel.fromJson(j))
                .toList(),
          );
          errorMessage.value = "";
          isLoading.value = false;
        } else {
          productList.clear();
          errorMessage.value = "No previously ordered products found.";
          isLoading.value = false;
        }
      } else {
        productList.clear();
        errorMessage.value = "Failed to load previously ordered products.";
        isLoading.value = false;
      }
    } catch (e) {
      if (!mounted) return;
      productList.clear();
      errorMessage.value = "An error occurred. Please try again.";
      isLoading.value = false;
    } finally {
      Globs.hideHUD();
    }
  }

  void navigateToProductDetail(OfferProductModel product) {
    Get.to(() => ProductDetails(pObj: product));
  }

  void addToCart(OfferProductModel product) {
    if (product.prodId != null) {
      CartViewModel.serviceCallAddToCart(product.prodId!, 1, () {
        cartVM.serviceCallList();
        Get.snackbar(
          "Added to Cart",
          "${product.name ?? "Product"} added to cart.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60), // Space for nav bar
              const SizedBox(height: 60), // Extra space below nav bar
              Expanded(
                child: Obx(() {
                  if (isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        errorMessage.value,
                        style: TextStyle(color: TColor.secondaryText, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ProductGridView(
                    products: productList,
                    minCardWidth: 90,
                    maxColumns: 3,
                    horizontalGap: 8,
                    gridHorizontalPadding: 16,
                    childAspectRatio: 0.45,
                    mainAxisSpacing: 20, // Ensures comfortable vertical spacing between cards
                    emptyMessage: "No previously ordered products found.",
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
                      // If needed, refresh data after modal closes:
                      // homeVM.serviceCallHome(); // (Optional)
},
                    onCart: (product) => addToCart(product),
                  );
                }),
              ),
            ],
          ),

          // Floating navigation bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomNavigationBar(),
          ),

          // Floating cart button
          const FloatingCartButton(),
        ],
      ),
    );
  }
}
