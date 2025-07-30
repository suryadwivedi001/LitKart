import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common/color_extension.dart';
import 'package:online_groceries/view_model/cart_view_model.dart';
import 'package:online_groceries/view/my_cart/my_cart_view.dart';

class FloatingCartButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool hideOnAccount;

  const FloatingCartButton({super.key, this.onTap, this.hideOnAccount = false});

  @override
  State<FloatingCartButton> createState() => _FloatingCartButtonState();
}

class _FloatingCartButtonState extends State<FloatingCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToCart() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Get.to(() => const MyCartView());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartVM = Get.find<CartViewModel>();
    return Obx(() {
      final bool shouldShow =
          cartVM.listArr.isNotEmpty && !widget.hideOnAccount;

      if (shouldShow) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }

      return shouldShow
          ? Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToCart,
                      borderRadius: BorderRadius.circular(33),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: TColor.primary, // <-- Pink!
                          borderRadius: BorderRadius.circular(33),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 26,
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "View Cart",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                    letterSpacing: 0.13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${cartVM.listArr.length} item${cartVM.listArr.length == 1 ? '' : 's'}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.89),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink();
    });
  }
}
