import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../model/offer_product_model.dart';
import '../model/cart_item_model.dart';
import '../view_model/cart_view_model.dart';
import 'package:online_groceries/common/color_extension.dart';

class ProductCell extends StatelessWidget {
  final OfferProductModel pObj;
  final VoidCallback onPressed;
  final double weight;
  final double margin;
  final VoidCallback? onCart;

  static const CrossAxisAlignment mainContentAlignment = CrossAxisAlignment.start;

  const ProductCell({
    super.key,
    required this.pObj,
    required this.onPressed,
    this.weight = 120,
    this.margin = .5,
    this.onCart,
  });

  double get randomRating => 3.9 + (Random().nextDouble() * 1.1);

  int getCartQuantity() {
    try {
      final cartVM = Get.find<CartViewModel>();
      final cartItem = cartVM.listArr.firstWhereOrNull(
        (item) => item.prodId == pObj.prodId,
      );
      return cartItem?.qty ?? 0;
    } catch (_) {
      return 0;
    }
  }

  CartItemModel? getCartItem() {
    try {
      final cartVM = Get.find<CartViewModel>();
      return cartVM.listArr.firstWhereOrNull(
        (item) => item.prodId == pObj.prodId,
      );
    } catch (_) {
      return null;
    }
  }

  void addToCart() {
    if (onCart != null) onCart!();
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

  bool get isPngImage {
    final imageUrl = pObj.image ?? '';
    return imageUrl.toLowerCase().endsWith('.png');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onPressed,
      child: Container(
        width: weight,
        margin: EdgeInsets.symmetric(
          horizontal: margin,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white, // Card bg is always white
          borderRadius: BorderRadius.circular(9),
          // No border, no shadow
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: mainContentAlignment,
              children: [
                // IMAGE section: Only has light grey background if it's a PNG
                Container(
                  decoration: BoxDecoration(
                    color: isPngImage ? const Color(0xFFF4F4F4) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                    child: CachedNetworkImage(
                      imageUrl: pObj.image ?? "",
                      width: double.infinity,
                      height: 125,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 125,
                        color: isPngImage ? const Color(0xFFF4F4F4) : Colors.white,
                        child: const Icon(Icons.image, size: 32, color: Colors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 125,
                        color: isPngImage ? const Color(0xFFF4F4F4) : Colors.white,
                        child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // CONTENT (always on white)
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 10, 10),
                    child: Column(
                      crossAxisAlignment: mainContentAlignment,
                      children: [
                        Text(
                          "\$${pObj.offerPrice ?? pObj.price ?? '0'}",
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        if ((pObj.unitValue?.isNotEmpty ?? false) || (pObj.unitName?.isNotEmpty ?? false))
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: Text(
                              "${pObj.unitValue ?? ""} ${pObj.unitName ?? ""}",
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3, top: 3),
                          child: Text(
                            pObj.name ?? "Product",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RatingBarIndicator(
                            rating: pObj.avgRating ?? randomRating,
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 14,
                            unratedColor: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 90,
              right: 8,
              child: Obx(() {
                final quantity = getCartQuantity();
                if (quantity == 0) {
                  return InkWell(
                    onTap: addToCart,
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: TColor.white.withOpacity(0.95),
                        border: Border.all(color: TColor.primary, width: 2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'ADD',
                        style: TextStyle(
                          color: TColor.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => updateQuantity(quantity - 1),
                          borderRadius: BorderRadius.circular(9),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                            child: Icon(Icons.remove, color: Colors.white, size: 15),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => updateQuantity(quantity + 1),
                          borderRadius: BorderRadius.circular(9),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                            child: Icon(Icons.add, color: Colors.white, size: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
