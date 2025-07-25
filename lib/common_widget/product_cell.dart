import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:online_groceries/common/color_extension.dart';

import '../model/offer_product_model.dart';

class ProductCell extends StatelessWidget {
  final OfferProductModel pObj;
  final VoidCallback onPressed;
  final VoidCallback onCart;
  final double margin;
  final double weight;

  const ProductCell(
      {super.key,
      required this.pObj,
      required this.onPressed,
      this.weight = 180,
      this.margin = 8,
      required this.onCart});

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
          border:
              Border.all(color: TColor.placeholder.withOpacity(0.5), width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: "http://192.168.1.13:3001${pObj.image ?? ""}",
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: 100,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const Spacer(),
            Text(
              pObj.name ?? "",
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              "${pObj.unitValue}${pObj.unitName}",
              style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w300),
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
                    onRatingUpdate: (rate) {}),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${pObj.offerPrice ?? pObj.price}",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
                InkWell(
                  onTap: onCart,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/img/add.png",
                      width: 15,
                      height: 15,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
