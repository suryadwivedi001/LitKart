import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common/color_extension.dart';
import 'package:online_groceries/view_model/cart_view_model.dart';

import '../model/offer_product_model.dart';
import '../model/cart_item_model.dart';

class ProductCell extends StatelessWidget {
  final OfferProductModel pObj;
  final VoidCallback onPressed;
  final VoidCallback? onCart; // Keep this for backward compatibility but make it optional
  final double margin;
  final double weight;

  const ProductCell({
    super.key,
    required this.pObj,
    required this.onPressed,
    this.onCart, // Optional parameter for backward compatibility
    this.weight = 180,
    this.margin = 8,
  });

  // Helper method to get current quantity in cart
  int getCartQuantity() {
    try {
      final cartVM = Get.find<CartViewModel>();
      final cartItem = cartVM.listArr.firstWhereOrNull(
        (item) => item.prodId == pObj.prodId,
      );
      return cartItem?.qty ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Helper method to get cart item
  CartItemModel? getCartItem() {
    try {
      final cartVM = Get.find<CartViewModel>();
      return cartVM.listArr.firstWhereOrNull(
        (item) => item.prodId == pObj.prodId,
      );
    } catch (e) {
      return null;
    }
  }

  // Add item to cart (first time)
  void addToCart() {
    CartViewModel.serviceCallAddToCart(pObj.prodId ?? 0, 1, () {
      Get.find<CartViewModel>().serviceCallList();
    });
  }

  // Update quantity in cart
  void updateQuantity(int newQty) {
    final cartItem = getCartItem();
    if (cartItem != null) {
      if (newQty <= 0) {
        // Remove item from cart
        Get.find<CartViewModel>().serviceCallRemoveCart(cartItem);
      } else {
        // Update quantity
        Get.find<CartViewModel>().serviceCallUpdateCart(cartItem, newQty);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: weight,
        margin: EdgeInsets.symmetric(horizontal: margin),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: TColor.placeholder.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed: Image overflow issue
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 100,
                    height: 80,
                    child: CachedNetworkImage(
                      imageUrl: pObj.image ?? "",
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                      width: 100,
                      height: 80,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              pObj.name ?? "",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              "${pObj.unitValue}${pObj.unitName}",
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            if ((pObj.avgRating ?? 0.0) > 0.0)
              IgnorePointer(
                ignoring: true,
                child: RatingBar.builder(
                  initialRating: pObj.avgRating ?? 0.0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 15,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rate) {},
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "\$${pObj.offerPrice ?? pObj.price}",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                // Blinkit-style ADD / Quantity Controller
                Obx(() {
                  final quantity = getCartQuantity();
                  
                  if (quantity == 0) {
                    // Show ADD button
                    return InkWell(
                      onTap: addToCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: TColor.primary, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Show quantity controller (- qty +)
                    return Container(
                      decoration: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Minus button
                          InkWell(
                            onTap: () => updateQuantity(quantity - 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          // Quantity display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Plus button
                          InkWell(
                            onTap: () => updateQuantity(quantity + 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
