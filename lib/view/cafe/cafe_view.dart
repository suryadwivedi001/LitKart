import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/cafe_view_model.dart';
import '../../common_widget/cafe_card.dart';

class CafeView extends StatelessWidget {
  CafeView({Key? key}) : super(key: key);

  final CafeViewModel cafeVM = Get.find<CafeViewModel>();
  final RxString searchTerm = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text("Cafe", style: TextStyle(color: Colors.black, fontSize: 17)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                  hintText: "Search Cafe",
                  prefixIcon: const Icon(Icons.search, size: 22),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none
                  )
                ),
                onChanged: (val) => searchTerm.value = val,
              ),
            ),
            // Visual Veg/Non-Veg toggles (no filter, UI only)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Obx(() {
                    return FilterChip(
                      showCheckmark: false,
                      selected: cafeVM.showVeg.value,
                      avatar: Icon(Icons.circle, color: Colors.green, size: 18),
                      label: const Text("Veg"),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green.shade100,
                      labelStyle: TextStyle(
                        color: cafeVM.showVeg.value ? Colors.green.shade900 : Colors.black87,
                        fontWeight: cafeVM.showVeg.value ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.green.shade300, width: 1.5),
                      ),
                      onSelected: (val) => cafeVM.toggleVeg(),
                    );
                  }),
                  const SizedBox(width: 8),
                  Obx(() {
                    return FilterChip(
                      showCheckmark: false,
                      selected: cafeVM.showNonVeg.value,
                      avatar: Icon(Icons.circle, color: Colors.red, size: 18),
                      label: const Text("Non-Veg"),
                      backgroundColor: Colors.white,
                      selectedColor: Colors.red.shade100,
                      labelStyle: TextStyle(
                        color: cafeVM.showNonVeg.value ? Colors.red.shade900 : Colors.black87,
                        fontWeight: cafeVM.showNonVeg.value ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.red.shade200, width: 1.5),
                      ),
                      onSelected: (val) => cafeVM.toggleNonVeg(),
                    );
                  }),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.only(left:10, right:16, top:8, bottom:8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1C2),
                      borderRadius: BorderRadius.circular(18)
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.flash_on, color: Colors.amber, size: 17),
                        SizedBox(width: 4),
                        Text(
                          "Delivery in 20 mins",
                          style: TextStyle(
                            color: Color(0xFFC2A400),
                            fontWeight: FontWeight.w700, fontSize: 14
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Responsive grid for 3 cards per row (like HomeView)
            Expanded(
              child: Obx(() {
                var items = cafeVM.cafeList;
                final q = searchTerm.value.trim().toLowerCase();
                if (q.isNotEmpty) {
                  items = items
                    .where((e) =>
                      (e.name ?? "").toLowerCase().contains(q) ||
                      (e.detail ?? "").toLowerCase().contains(q)
                    ).toList().obs;
                }
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      "Cafe items coming soon!",
                      style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid calculation (like HomeView)
                    const double minCardWidth = 90;
                    const int maxColumns = 3;
                    const double horizontalGap = 8;
                    const double gridHorizontalPadding = 0;
                    final screenWidth = constraints.maxWidth;
                    int columns = (screenWidth / (minCardWidth + horizontalGap)).floor();
                    columns = columns.clamp(2, maxColumns);
                    final totalGaps = (columns - 1) * horizontalGap;
                    final cardWidth = ((screenWidth - 2 * gridHorizontalPadding) - totalGaps) / columns;

                    return GridView.builder(
                      itemCount: items.length,
                      padding: const EdgeInsets.only(bottom: 6),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: horizontalGap,
                        mainAxisSpacing: 9,
                        childAspectRatio: 0.70,
                      ),
                      itemBuilder: (context, index) {
                        final product = items[index];
                        return CafeCard(
                          product: product,
                          // If using weight in CafeCard, pass `weight: cardWidth,`
                        );
                      },
                    );
                  }
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
