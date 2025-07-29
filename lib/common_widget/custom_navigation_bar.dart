import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common/color_extension.dart';
import 'package:online_groceries/view_model/cart_view_model.dart';
import 'package:online_groceries/view_model/addres_view_mode.dart';
import 'package:online_groceries/model/address_model.dart';
import 'package:online_groceries/view/my_cart/my_cart_view.dart';
import 'package:online_groceries/view/account/address_list_view.dart';

class CustomNavigationBar extends StatefulWidget {
  final VoidCallback? onCartTap;
  final bool showCartBadge;

  const CustomNavigationBar({
    super.key,
    this.onCartTap,
    this.showCartBadge = true,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  String selectedLocation = "Dhaka, Banassre";
  final addressVM = Get.put(AddressViewModel());

  @override
  void initState() {
    super.initState();
    _initSelectedLocation();
  }

  void _initSelectedLocation() {
    if (addressVM.listArr.isNotEmpty) {
      final defaultAddress = addressVM.listArr.firstWhere(
        (address) => address.isDefault == 1,
        orElse: () => addressVM.listArr.first,
      );
      setState(() {
        selectedLocation = _formatAddressForDisplay(defaultAddress);
      });
    }
  }

  void _handleLocationTap() {
    Get.to(() => AddressListView(
      didSelect: (AddressModel selectedAddress) {
        setState(() {
          selectedLocation = _formatAddressForDisplay(selectedAddress);
        });
      },
    ));
  }

  String _formatAddressForDisplay(AddressModel address) {
    if ((address.city ?? '').isNotEmpty) {
      if ((address.state ?? '').isNotEmpty) {
        return "${address.city}, ${address.state}";
      }
      return address.city!;
    } else if ((address.name ?? '').isNotEmpty) {
      return address.name!;
    } else if ((address.address ?? '').isNotEmpty) {
      final parts = address.address!.split(',');
      return parts.first.trim();
    }
    return "Select Address";
  }

  void _navigateToCart() {
    if (widget.onCartTap != null) {
      widget.onCartTap!();
    } else {
      Get.to(() => const MyCartView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Location dropdown (left)
            Expanded(
              child: InkWell(
                onTap: _handleLocationTap,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/img/location.png",
                      width: 18,
                      height: 18,
                      color: TColor.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Deliver to",
                            style: TextStyle(
                              color: TColor.secondaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            selectedLocation,
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: TColor.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            // Cart icon (right, updates real time)
            Obx(() {
              final cartVM = Get.find<CartViewModel>();
              final itemCount = cartVM.listArr.length;

              return InkWell(
                onTap: _navigateToCart,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/img/cart_tab.png",
                        width: 28,
                        height: 28,
                        color: TColor.primaryText,
                      ),
                      if (widget.showCartBadge && itemCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: TColor.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              itemCount > 99 ? '99+' : itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
