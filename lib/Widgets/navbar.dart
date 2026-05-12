// import 'package:flutter/material.dart';

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final scale = width / 390;

//     final barWidth = 250 * scale;
//     final barHeight = 58 * scale;
//     final pillWidth = 42 * scale;
//     final pillHeight = 30 * scale;
//     final slotWidth = barWidth / 4;

//     final List<IconData> icons = [
//       Icons.home_rounded,
//       Icons.settings_rounded,
//       Icons.photo_library_rounded,
//       Icons.auto_awesome_rounded,
//     ];

//     return Padding(
//       padding: EdgeInsets.only(bottom: 14 * scale),
//       child: SizedBox(
//         width: barWidth,
//         height: barHeight,
//         child: DecoratedBox(
//           decoration: BoxDecoration(
//             color: const Color(0xFFF5D8C3),
//             borderRadius: BorderRadius.circular(100),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.12),
//                 blurRadius: 20 * scale,
//                 offset: Offset(0, 8 * scale),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               /// ACTIVE PILL
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 250),
//                 curve: Curves.easeOut,
//                 left: currentIndex * slotWidth +
//                     (slotWidth - pillWidth) / 2,
//                 top: (barHeight - pillHeight) / 2,
//                 child: Container(
//                   width: pillWidth,
//                   height: pillHeight,
//                   decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                 ),
//               ),

//               /// ICONS
//               Row(
//                 children: List.generate(
//                   icons.length,
//                   (index) {
//                     final isSelected = currentIndex == index;

//                     return Expanded(
//                       child: GestureDetector(
//                         behavior: HitTestBehavior.opaque,
//                         onTap: () => onTap(index),
//                         child: Center(
//                           child: AnimatedScale(
//                             duration: const Duration(milliseconds: 200),
//                             scale: isSelected ? 1.05 : 1,
//                             child: Icon(
//                               icons[index],
//                               size: 22 * scale,
//                               color: isSelected
//                                   ? Colors.white
//                                   : const Color(0xFFB1937F),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 390;

    final barWidth = 250 * scale;
    final barHeight = 58 * scale;
    final pillWidth = 42 * scale;
    final pillHeight = 30 * scale;
    final slotWidth = barWidth / 4;

    final List<IconData> icons = [
      Icons.home_rounded,
      Icons.settings_rounded,
      Icons.photo_library_rounded,
      Icons.auto_awesome_rounded,
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: 14 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: barWidth,
            height: barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF5D8C3),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  /// ACTIVE PILL
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    left: currentIndex * slotWidth +
                        (slotWidth - pillWidth) / 2,
                    top: (barHeight - pillHeight) / 2,
                    child: Container(
                      width: pillWidth,
                      height: pillHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  /// ICONS
                  Row(
                    children: List.generate(
                      icons.length,
                      (index) {
                        final isSelected = currentIndex == index;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(index),
                            child: Center(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: isSelected ? 1.05 : 1,
                                child: Icon(
                                  icons[index],
                                  size: 22 * scale,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFB1937F),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}