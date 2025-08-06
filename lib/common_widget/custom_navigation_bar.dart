import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_groceries/common/color_extension.dart';
import 'package:online_groceries/view_model/addres_view_mode.dart';
import 'package:online_groceries/model/address_model.dart';
import 'package:online_groceries/view/account/address_list_view.dart';
import 'package:online_groceries/view/account/account_view.dart';

class CustomNavigationBar extends StatefulWidget {
  final VoidCallback? onCartTap;
  final bool showCartBadge;
  final ValueChanged<String>? onSearchChanged; // optional search callback

  const CustomNavigationBar({
    super.key,
    this.onCartTap,
    this.showCartBadge = true,
    this.onSearchChanged,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  String selectedLocation = "Dhaka, Banassre";
  final addressVM = Get.put(AddressViewModel());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSelectedLocation();
    _searchController.addListener(() {
      if (widget.onSearchChanged != null) {
        widget.onSearchChanged!(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _navigateToAccount() {
    if (widget.onCartTap != null) {
      widget.onCartTap!();
    } else {
      Get.to(() => const AccountView());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: location and profile/account
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location & drop-down
                InkWell(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: TColor.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                // Profile/account icon
                InkWell(
                  onTap: _navigateToAccount,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      "assets/img/account_tab.png",
                      width: 28,
                      height: 28,
                      color: TColor.primaryText,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Full-width search bar (below the top row)
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffF2F3F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      "assets/img/search.png",
                      width: 18,
                      height: 18,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  hintText: "Search Store",
                  hintStyle: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
