import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common/color_extension.dart';
import 'package:online_groceries/view_model/cart_view_model.dart';
import 'dart:math';

import '../model/offer_product_model.dart';
import '../model/cart_item_model.dart';

class ProductCell extends StatelessWidget {
  final OfferProductModel pObj;
  final VoidCallback onPressed;
  final VoidCallback? onCart;
  final double margin;
  final double weight;

  const ProductCell({
    super.key,
    required this.pObj,
    required this.onPressed,
    this.onCart,
    this.weight = 140, // Reduced from 180 to 140
    this.margin = 6, // Reduced margin for compactness
  });

  // Generate random rating between 3.9 and 5.0
  double get randomRating {
    final random = Random();
    return 3.9 + (random.nextDouble() * 1.1); // 3.9 to 5.0
  }

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
        Get.find<CartViewModel>().serviceCallRemoveCart(cartItem);
      } else {
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
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: TColor.placeholder.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(12), // Slightly smaller radius
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact image section
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 70, // Smaller image
                  height: 60, // Smaller height
                  child: CachedNetworkImage(
                    imageUrl: pObj.image ?? "",
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error, size: 20),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Product name (compact)
            Text(
              pObj.name ?? "",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 11, // Smaller font
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            
            // Unit info
            Text(
              "${pObj.unitValue}${pObj.unitName}",
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 10, // Smaller font
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 4),
            
            // Always show star rating with random value
            IgnorePointer(
              ignoring: true,
              child: RatingBar.builder(
                initialRating: pObj.avgRating ?? randomRating, // Use backend rating if available, otherwise random
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 12, // Smaller stars
                itemPadding: const EdgeInsets.symmetric(horizontal: 0.5),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber, // Golden color
                ),
                onRatingUpdate: (rate) {},
              ),
            ),
            const SizedBox(height: 6),
            
            // Price and cart section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "\$${pObj.offerPrice ?? pObj.price}",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 13, // Slightly smaller
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Compact ADD / Quantity Controller
                Obx(() {
                  final quantity = getCartQuantity();
                  
                  if (quantity == 0) {
                    // Compact ADD button
                    return InkWell(
                      onTap: addToCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: TColor.primary, width: 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ADD',
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Compact quantity controller
                    return Container(
                      decoration: BoxDecoration(
                        color: TColor.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => updateQuantity(quantity - 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => updateQuantity(quantity + 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 12,
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
