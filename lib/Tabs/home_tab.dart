import 'package:flutter/material.dart';
import 'photo_screen.dart';
import 'duplicates.dart';
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  final List<Map<String, dynamic>> timeline = const [
    {
      "month": "APR '26",
      "count": "1,246",
      "color": Color(0xFFFF4DA6),
    },
    {
      "month": "MAR '26",
      "count": "842",
      "color": Color(0xFF00B86B),
    },
    {
      "month": "FEB '26",
      "count": "623",
      "color": Color(0xFFFF5B6E),
    },
    {
      "month": "JAN '26",
      "count": "511",
      "color": Color(0xFF5C7CFA),
    },
    {
      "month": "DEC '25",
      "count": "328",
      "color": Color(0xFF1C4ED8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final scale = width / 390;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          children: [

            /// SCROLLABLE CONTENT
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  /// FEATURE CARDS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20 * scale,
                      ),
                      child: Column(
                        children: [
                          _featureCard(
                            context: context,
                            scale: scale,
                            title: "Recents",
                            subtitle: "9 new photos",
                            icon: Icons.access_time_rounded,
                            colors: const [
                              Color(0xFF00D2FF),
                              Color(0xFF2563FF),
                            ],
                            badge: "9",
                          ),

                          SizedBox(height: 18 * scale),

                          _featureCard(
                            context: context,
                            scale: scale,
                            title: "Random",
                            subtitle: "Shuffle your memories",
                            icon: Icons.shuffle_rounded,
                            colors: const [
                              Color(0xFF4F46E5),
                              Color(0xFFC026FF),
                            ],
                          ),

                          SizedBox(height: 18 * scale),

                          _featureCard(
                            context: context,
                            scale: scale,
                            title: "Duplicates",
                            subtitle:
                                "Clean up similar photos",
                            icon:
                                Icons.photo_library_outlined,
                            colors: const [
                              Color(0xFFFF8A00),
                              Color(0xFFFFD600),
                            ],
                            routeTo: const DuplicatesScreen(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// TITLE
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        22 * scale,
                        32 * scale,
                        22 * scale,
                        18 * scale,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.blueGrey,
                            size: 20 * scale,
                          ),

                          SizedBox(width: 10 * scale),

                          Expanded(
                            child: Text(
                              "YOUR TIMELINE",
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    Colors.blueGrey.shade500,
                                fontWeight:
                                    FontWeight.w700,
                                letterSpacing: 1,
                                fontSize: 12 * scale,
                              ),
                            ),
                          ),

                          Icon(
                            Icons.tune_rounded,
                            color:
                                Colors.blueGrey.shade500,
                            size: 20 * scale,
                          )
                        ],
                      ),
                    ),
                  ),

                  /// TIMELINE
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                    ),
                    sliver: SliverList.builder(
                      itemCount: timeline.length,
                      itemBuilder: (context, index) {
                        final item = timeline[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 14 * scale,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PhotoScreen(),
                                ),
                              );
                            },
                            child: _timelineCard(
                              scale: scale,
                              month: item["month"],
                              count: item["count"],
                              color: item["color"],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100 * scale,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required BuildContext context,
    required double scale,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    String? badge,
    Widget? routeTo,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => routeTo ?? const PhotoScreen(),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          minHeight: 125 * scale,
        ),
        padding: EdgeInsets.all(18 * scale),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius:
              BorderRadius.circular(26 * scale),
          boxShadow: [
            BoxShadow(
              color:
                  colors.last.withOpacity(0.22),
              blurRadius: 16 * scale,
              offset: Offset(0, 8 * scale),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62 * scale,
              height: 62 * scale,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32 * scale,
              ),
            ),

            SizedBox(width: 16 * scale),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22 * scale,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 4 * scale),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(0.92),
                      fontSize: 13 * scale,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),

            SizedBox(width: 10 * scale),

            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                if (badge != null)
                  Container(
                    width: 44 * scale,
                    height: 44 * scale,
                    decoration:
                        const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight:
                              FontWeight.w800,
                          fontSize:
                              18 * scale,
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: 10 * scale),

                Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16 * scale,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _timelineCard({
    required double scale,
    required String month,
    required String count,
    required Color color,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 95 * scale,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5 * scale,
            height: 52 * scale,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(100),
            ),
          ),

          SizedBox(width: 14 * scale),

          Container(
            width: 54 * scale,
            height: 54 * scale,
            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: color,
              size: 26 * scale,
            ),
          ),

          SizedBox(width: 16 * scale),

          Expanded(
            child: Text(
              month,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.w800,
                fontSize: 22 * scale,
              ),
            ),
          ),

          SizedBox(width: 8 * scale),

          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 7 * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                        100),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  count,
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    fontSize:
                        14 * scale,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 8 * scale),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
            size: 16 * scale,
          )
        ],
      ),
    );
  }
}