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
    this.weight = 140,
    this.margin = 6,
  });

  double get randomRating {
    final random = Random();
    return 3.9 + (random.nextDouble() * 1.1);
  }

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

  void addToCart() {
    CartViewModel.serviceCallAddToCart(pObj.prodId ?? 0, 1, () {
      Get.find<CartViewModel>().serviceCallList();
    });
  }

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
        height: 160, // FIXED HEIGHT - This prevents any vertical overflow
        margin: EdgeInsets.symmetric(horizontal: margin),
        padding: const EdgeInsets.all(10), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: TColor.placeholder.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ULTRA-SAFE IMAGE SECTION
            Center(
              child: Container(
                width: 60, // Smaller image to ensure fit
                height: 50, // Smaller height
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xffF2F3F2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: pObj.image ?? "",
                    width: 60,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 50,
                      color: const Color(0xffF2F3F2),
                      child: const Icon(Icons.image, size: 16, color: Colors.grey),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 50,
                      color: const Color(0xffF2F3F2),
                      child: const Icon(Icons.broken_image, size: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            
            // CONSTRAINED TEXT SECTION
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name with strict constraints
                  SizedBox(
                    height: 26, // Fixed height for 2 lines
                    child: Text(
                      pObj.name ?? "Product",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 10, // Smaller font
                        fontWeight: FontWeight.w500,
                        height: 1.2, // Control line height
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Unit info
                  SizedBox(
                    height: 12, // Fixed height
                    child: Text(
                      "${pObj.unitValue ?? ''}${pObj.unitName ?? ''}",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 9, // Smaller font
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  
                  // Star rating
                  SizedBox(
                    height: 14, // Fixed height for stars
                    child: RatingBar.builder(
                      initialRating: pObj.avgRating ?? randomRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 10, // Smaller stars
                      itemPadding: const EdgeInsets.symmetric(horizontal: 0.2),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rate) {},
                      ignoreGestures: true,
                    ),
                  ),
                ],
              ),
            ),
            
            // BOTTOM SECTION - Price and Controls
            SizedBox(
              height: 24, // Fixed height for bottom section
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "\$${pObj.offerPrice ?? pObj.price ?? '0'}",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 11, // Smaller font
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  
                  // Compact cart controls
                  Obx(() {
                    final quantity = getCartQuantity();
                    
                    if (quantity == 0) {
                      return InkWell(
                        onTap: addToCart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: TColor.primary, width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ADD',
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 12, // Smaller font
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        height: 28, // Fixed height
                        decoration: BoxDecoration(
                          color: TColor.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => updateQuantity(quantity - 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                quantity.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => updateQuantity(quantity + 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
