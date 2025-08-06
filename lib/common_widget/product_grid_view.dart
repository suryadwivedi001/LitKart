import 'package:flutter/material.dart';
import '../model/offer_product_model.dart';
import 'product_cell.dart';

class ProductGridView extends StatelessWidget {
  final List<OfferProductModel> products;
  final double minCardWidth;
  final int maxColumns;
  final double horizontalGap;
  final double gridHorizontalPadding;
  final double childAspectRatio;
  final double mainAxisSpacing;  // Added vertical spacing parameter
  final String? emptyMessage;
  final void Function(OfferProductModel)? onProductTap;
  final void Function(OfferProductModel)? onCart;

  /// Optional parameters to control scrolling behavior of the grid
  final ScrollPhysics? scrollPhysics;
  final bool shrinkWrap;

  const ProductGridView({
    Key? key,
    required this.products,
    this.minCardWidth = 90,
    this.maxColumns = 3,
    this.horizontalGap = 8,
    this.gridHorizontalPadding = 8,
    this.childAspectRatio = 0.45,
    this.mainAxisSpacing = 9,        // Default vertical spacing (can be overridden)
    this.emptyMessage = "No products found.",
    this.onProductTap,
    this.onCart,
    this.scrollPhysics,
    this.shrinkWrap = false,         // Default false to allow natural scrolling
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
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: gridHorizontalPadding),
          child: GridView.builder(
            itemCount: products.length,
            shrinkWrap: shrinkWrap,
            physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: horizontalGap,
              mainAxisSpacing: mainAxisSpacing,     // Use configurable mainAxisSpacing
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
