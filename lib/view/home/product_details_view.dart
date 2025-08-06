import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/color_extension.dart';
import '../../model/offer_product_model.dart';
import '../../view_model/cart_view_model.dart';
import '../../view_model/product_detail_view_model.dart';

class ProductDetails extends StatefulWidget {
  final OfferProductModel pObj;
  final bool asModalSheet;

  const ProductDetails({
    super.key,
    required this.pObj,
    this.asModalSheet = false,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late ProductDetailViewMode detailVM;

  @override
  void initState() {
    super.initState();
    detailVM = Get.put(ProductDetailViewMode(widget.pObj));
  }

  @override
  void dispose() {
    Get.delete<ProductDetailViewMode>();
    super.dispose();
  }

  Widget buildHandleBar() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        width: 45,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.23;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: CachedNetworkImage(
        imageUrl: detailVM.pObj.image ?? "",
        width: double.infinity,
        height: imageHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: imageHeight,
          alignment: Alignment.center,
          color: Colors.grey[100],
          child: const CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          height: imageHeight,
          alignment: Alignment.center,
          color: Colors.grey[200],
          child: const Icon(Icons.error, size: 40),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and subinfo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detailVM.pObj.name ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "${detailVM.pObj.unitValue ?? ""}${detailVM.pObj.unitName ?? ""}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if ((detailVM.pObj.avgRating ?? 0.0) > 0.0) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[800], size: 16),
                      const SizedBox(width: 3),
                      Text(
                        "${detailVM.pObj.avgRating!.toStringAsFixed(1)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                detailVM.isFav.value
                    ? Icons.favorite
                    : Icons.favorite_outline,
                color: detailVM.isFav.value ? Colors.red : Colors.grey,
              ),
              onPressed: () => detailVM.serviceCallAddRemoveFavorite(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget buildDetailsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Detail expandable
          Row(
            children: [
              const Expanded(
                child: Text("Product Detail",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              Obx(
                () => IconButton(
                  onPressed: () => detailVM.showDetail(),
                  icon: Icon(
                    detailVM.isShowDetail.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 22,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => detailVM.isShowDetail.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      detailVM.pObj.detail ?? "-",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : Container(),
          ),
          Divider(),
          Row(
            children: [
              const Expanded(
                child: Text("Nutritions",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                  color: TColor.placeholder.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  detailVM.pObj.nutritionWeight ?? "100gr",
                  style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Obx(
                () => IconButton(
                  onPressed: () => detailVM.showNutrition(),
                  icon: Icon(
                    detailVM.isShowNutrition.value
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 22,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => detailVM.isShowNutrition.value
                ? ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var nObj = detailVM.nutritionList[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            nObj.nutritionName ?? "",
                            style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            nObj.nutritionValue ?? "",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(color: Colors.black12),
                    itemCount: detailVM.nutritionList.length)
                : Container(),
          ),
        ],
      ),
    );
  }

Widget buildAddCartBar(BuildContext context) {
  final cartVM = Get.find<CartViewModel>();

  double getProductUnitPrice() =>
      double.tryParse('${widget.pObj.offerPrice ?? widget.pObj.price ?? 0}') ?? 0.0;

  final showStriked = widget.pObj.offerPrice != null &&
      widget.pObj.offerPrice != widget.pObj.price;

  return Obx(() {
    final cartItem = cartVM.listArr.firstWhereOrNull(
      (item) => item.prodId == widget.pObj.prodId,
    );
    final qty = cartItem?.qty ?? 0;
    final price = getProductUnitPrice();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '₹${qty > 0 ? (qty * price).toStringAsFixed(2) : price.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
              fontSize: 19,
            ),
          ),
          if (showStriked && qty <= 1)
            Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Text(
                '₹${widget.pObj.price}',
                style: TextStyle(
                  color: TColor.secondaryText.withOpacity(0.79),
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          const Spacer(),
          // Show "ADD" button if qty == 0
          if (qty == 0)
            InkWell(
              onTap: () async {
                await CartViewModel.serviceCallAddToCart(
                  widget.pObj.prodId ?? 0,
                  1,
                  () async {
                    cartVM.serviceCallList(); // Refresh cart after add
                  },
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: TColor.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "ADD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.primary,
                    letterSpacing: 1,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            // Quantity controls with "-" and "+" buttons
            Container(
              decoration: BoxDecoration(
                color: TColor.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      if (cartItem == null) return;
                      if (qty > 1) {
                        cartVM.serviceCallUpdateCart(cartItem, qty - 1);
                      } else if (qty == 1) {
                        cartVM.serviceCallRemoveCart(cartItem);
                      }
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Icon(Icons.remove, color: Colors.white, size: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (cartItem != null) {
                        // Use updateCart to increment quantity explicitly
                        cartVM.serviceCallUpdateCart(cartItem, qty + 1);
                      } else {
                        // Fallback: Add product if not found in cart (qty=0)
                        await CartViewModel.serviceCallAddToCart(
                          widget.pObj.prodId ?? 0,
                          1,
                          () async {
                            cartVM.serviceCallList();
                          },
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    if (widget.asModalSheet) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildHandleBar(),
              buildImage(context),
              buildHeader(context),
              const Divider(height: 1),
              Expanded(child: SingleChildScrollView(child: buildDetailsList())),
              buildAddCartBar(context),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            Obx(
              () => IconButton(
                icon: Icon(
                  detailVM.isFav.value
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  color: detailVM.isFav.value ? Colors.red : Colors.grey,
                ),
                onPressed: () => detailVM.serviceCallAddRemoveFavorite(),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            buildImage(context),
            buildHeader(context),
            const Divider(height: 1),
            Expanded(child: SingleChildScrollView(child: buildDetailsList())),
            buildAddCartBar(context),
          ],
        ),
      );
    }
  }
}
