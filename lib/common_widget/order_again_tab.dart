import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../common/color_extension.dart';
import '../common/globs.dart';
import '../model/offer_product_model.dart';
import '../common_widget/product_cell.dart';
import '../view/home/product_details_view.dart';
import '../view_model/cart_view_model.dart';
import '../view_model/splash_view_model.dart';

class OrderAgainTab extends StatefulWidget {
  const OrderAgainTab({super.key});

  @override
  State<OrderAgainTab> createState() => _OrderAgainTabState();
}

class _OrderAgainTabState extends State<OrderAgainTab> {
  List<OfferProductModel> productList = [];
  bool isLoading = true;
  String errorMessage = "";

  final CartViewModel cartVM = Get.find<CartViewModel>();

  late final SplashViewModel splashVM;

  @override
  void initState() {
    super.initState();
    splashVM = Get.find<SplashViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPreviouslyOrderedProducts();
    });
  }

  Future<void> fetchPreviouslyOrderedProducts() async {
    try {
      Globs.showHUD(status: "Loading...");

      String authToken = splashVM.userPayload.value.authToken ?? "";
      if (authToken.isEmpty) {
        setState(() {
          errorMessage = "Please log in to view previously ordered products.";
          productList = [];
          isLoading = false;
        });
        Globs.hideHUD();
        return;
      }

      final url = SVKey.svOrderAgain;

      final response = await GetConnect().post(
        url,
        {}, // empty POST body as API requires
        headers: {
          "access_token": authToken,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = response.body;
        if (body["status"] == "1" &&
            body["payload"] != null &&
            body["payload"]["product_list"] != null) {
          setState(() {
            productList = (body["payload"]["product_list"] as List)
                .map((j) => OfferProductModel.fromJson(j))
                .toList();
            errorMessage = "";
            isLoading = false;
          });
        } else {
          setState(() {
            productList = [];
            errorMessage = "No previously ordered products found.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          productList = [];
          errorMessage = "Failed to load previously ordered products.";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "An error occurred. Please try again.";
        productList = [];
        isLoading = false;
      });
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Order Again",
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: TColor.secondaryText, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive grid calculation (3 per row if wide enough)
                      const double minCardWidth = 90;
                      const int maxColumns = 3;
                      const double horizontalGap = 8;
                      const double gridHorizontalPadding = 0;
                      final screenWidth = constraints.maxWidth;
                      int columns = (screenWidth / (minCardWidth + horizontalGap)).floor();
                      columns = columns.clamp(2, maxColumns);
                      final totalGaps = (columns - 1) * horizontalGap;
                      final cardWidth = ((screenWidth - 2 * gridHorizontalPadding) - totalGaps) / columns;

                      if (productList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              "No previously ordered products found.",
                              style: TextStyle(color: TColor.secondaryText),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        itemCount: productList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: horizontalGap,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.45,
                        ),
                        itemBuilder: (context, index) {
                          final product = productList[index];
                          return ProductCell(
                            pObj: product,
                            margin: 0,
                            weight: cardWidth,
                            onPressed: () => navigateToProductDetail(product),
                            onCart: () => addToCart(product),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
