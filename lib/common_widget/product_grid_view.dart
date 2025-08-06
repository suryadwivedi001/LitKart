import 'package:flutter/material.dart';
import '../model/offer_product_model.dart'; // or use a generic type with a builder, see below
import 'product_cell.dart';

class ProductGridView extends StatelessWidget {
  final List<OfferProductModel> products;
  final double minCardWidth;
  final int maxColumns;
  final double horizontalGap;
  final double gridHorizontalPadding;
  final double childAspectRatio;
  final String? emptyMessage;
  final void Function(OfferProductModel)? onProductTap;
  final void Function(OfferProductModel)? onCart;

  const ProductGridView({
    Key? key,
    required this.products,
    this.minCardWidth = 90,
    this.maxColumns = 3,
    this.horizontalGap = 8,
    this.gridHorizontalPadding = 8,
    this.childAspectRatio = 0.45,
    this.emptyMessage = "No products found.",
    this.onProductTap,
    this.onCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int columns = (screenWidth / (minCardWidth + horizontalGap)).floor();
        columns = columns.clamp(2, maxColumns);
        final totalGaps = (columns - 1) * horizontalGap;
        final cardWidth = ((screenWidth - 2 * gridHorizontalPadding) - totalGaps) / columns;

        if (products.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                emptyMessage ?? "No products found.",
                style: const TextStyle(color: Colors.grey), // Or your TColor.secondaryText
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: gridHorizontalPadding),
          child: GridView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: horizontalGap,
              mainAxisSpacing: 9,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final pObj = products[index];
              return ProductCell(
                pObj: pObj,
                margin: 0,
                weight: cardWidth,
                onPressed: () => onProductTap?.call(pObj),
                onCart: () => onCart?.call(pObj),
              );
            },
          ),
        );
      },
    );
  }
}
