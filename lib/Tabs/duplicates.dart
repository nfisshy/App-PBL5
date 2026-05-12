import 'package:flutter/material.dart';

class DuplicatesScreen extends StatelessWidget {
  const DuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = size.width / 390;

    final List<Map<String, dynamic>> duplicateGroups = [
      {
        "count": 4,
        "image": "https://picsum.photos/500/700?1",
      },
      {
        "count": 3,
        "image": "https://picsum.photos/500/700?2",
      },
      {
        "count": 3,
        "image": "https://picsum.photos/500/700?3",
      },
      {
        "count": 2,
        "image": "https://picsum.photos/500/700?4",
      },
      {
        "count": 2,
        "image": "https://picsum.photos/500/700?5",
      },
      {
        "count": 3,
        "image": "https://picsum.photos/500/700?6",
      },
      {
        "count": 2,
        "image": "https://picsum.photos/500/700?7",
      },
      {
        "count": 4,
        "image": "https://picsum.photos/500/700?8",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3D0BC),
      body: SafeArea(
        child: Column(
          children: [
            /// TOP BAR
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22 * scale,
                vertical: 10 * scale,
              ),
              child: Row(
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    scale: scale,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        "DUPLICATES",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30 * scale,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ),

                  _circleButton(
                    icon: Icons.tune_rounded,
                    scale: scale,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 10 * scale),

            /// STORAGE CARD
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 22 * scale,
              ),
              child: Container(
                padding: EdgeInsets.all(18 * scale),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(
                    28 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58 * scale,
                      height: 58 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB57BFF),
                        borderRadius: BorderRadius.circular(
                          18 * scale,
                        ),
                      ),
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: Colors.white,
                        size: 30 * scale,
                      ),
                    ),

                    SizedBox(width: 16 * scale),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "24 duplicate photos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 4 * scale),

                          Text(
                            "You can free up 1.8 GB",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * scale,
                        vertical: 10 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7DFFA7),
                        borderRadius: BorderRadius.circular(
                          100,
                        ),
                      ),
                      child: Text(
                        "CLEAN",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 22 * scale),

            /// GRID
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 22 * scale,
                ),
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18 * scale,
                  mainAxisSpacing: 22 * scale,
                  childAspectRatio: 0.78,
                ),
                itemCount: duplicateGroups.length,
                itemBuilder: (context, index) {
                  final item = duplicateGroups[index];

                  return GestureDetector(
                    onTap: () {},
                    child: _duplicateCard(
                      image: item['image'],
                      count: item['count'],
                      scale: scale,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _duplicateCard({
    required String image,
    required int count,
    required double scale,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// STACKED CARD EFFECT
        Positioned(
          top: 12 * scale,
          left: 12 * scale,
          right: -2 * scale,
          bottom: -2 * scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                28 * scale,
              ),
              color: Colors.black.withOpacity(0.12),
            ),
          ),
        ),

        Positioned(
          top: 6 * scale,
          left: 6 * scale,
          right: -1 * scale,
          bottom: -1 * scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                28 * scale,
              ),
              color: Colors.black.withOpacity(0.08),
            ),
          ),
        ),

        /// MAIN CARD
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              28 * scale,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              28 * scale,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  image,
                  fit: BoxFit.cover,
                ),

                /// DARK OVERLAY
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.05),
                        Colors.transparent,
                        Colors.black.withOpacity(0.28),
                      ],
                    ),
                  ),
                ),

                /// BOTTOM INFO
                Positioned(
                  left: 14 * scale,
                  right: 14 * scale,
                  bottom: 14 * scale,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 54 * scale,
                        height: 54 * scale,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "$count",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24 * scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * scale,
                          vertical: 10 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(
                            100,
                          ),
                          border: Border.all(
                            color:
                                Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.layers_rounded,
                              color: Colors.white,
                              size: 16 * scale,
                            ),

                            SizedBox(width: 6 * scale),

                            Text(
                              "VIEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required double scale,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62 * scale,
        height: 62 * scale,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 30 * scale,
        ),
      ),
    );
  }
}
