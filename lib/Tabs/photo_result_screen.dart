import 'package:flutter/material.dart';

class SwipeResultScreen
    extends StatelessWidget {
  const SwipeResultScreen({
    super.key,
    required this.sessionTitle,
    required this.keepCount,
    required this.deleteCount,
    required this.savedBytes,
    required this.totalSavedBytes,
  });

  final String sessionTitle;
  final int keepCount;
  final int deleteCount;
  final int savedBytes;
  final int totalSavedBytes;

  static const Color _green =
      Color(0xFF72FFB4);

  static const Color _purple =
      Color(0xFFB57BFF);

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.sizeOf(context)
            .width /
        390;

    final savedText =
        _formatBytes(savedBytes);

    return Scaffold(
      backgroundColor:
          const Color(0xFF171211),

      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(
            horizontal:
                26 * scale,
          ),

          child: Column(
            children: [
              /// TOP
              Padding(
                padding:
                    EdgeInsets.only(
                  top: 8 * scale,
                ),

                child: Row(
                  children: [
                    const Spacer(),

                    GestureDetector(
                      onTap: () {
                    Navigator.popUntil(
                      context,
                      (route) =>
                          route
                              .isFirst,
                    );
                      },

                      child: Icon(
                        Icons.close_rounded,
                        color:
                            Colors
                                .white,
                        size:
                            40 *
                            scale,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 50 * scale,
              ),

              /// TITLE
              Text(
                sessionTitle,
                style: TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      28 * scale,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),

              SizedBox(
                height: 22 * scale,
              ),

              /// BIG SIZE
              RichText(
                textAlign:
                    TextAlign.center,

                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          savedText
                              .split(
                                " ",
                              )
                              .first,

                      style:
                          TextStyle(
                        color:
                            Colors
                                .white,

                        fontSize:
                            84 *
                            scale,

                        fontWeight:
                            FontWeight
                                .w900,

                        height:
                            0.95,
                      ),
                    ),

                    TextSpan(
                      text:
                          savedText.contains(
                                " ",
                              )
                              ? savedText
                                  .split(
                                    " ",
                                  )[1]
                              : "",

                      style:
                          TextStyle(
                        color:
                            Colors
                                .white,

                        fontSize:
                            40 *
                            scale,

                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 8 * scale,
              ),

              Text(
                "saved",
                style: TextStyle(
                  color:
                      Colors.white,

                  fontSize:
                      28 * scale,

                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),

              SizedBox(
                height: 46 * scale,
              ),

              /// STATS
              Row(
                children: [
                  Expanded(
                    child:
                        _statCard(
                      scale:
                          scale,

                      number:
                          keepCount
                              .toString(),

                      label:
                          "KEEP",

                      icon:
                          Icons
                              .check_rounded,

                      color:
                          _green,
                    ),
                  ),

                  SizedBox(
                    width:
                        18 *
                        scale,
                  ),

                  Expanded(
                    child:
                        _statCard(
                      scale:
                          scale,

                      number:
                          deleteCount
                              .toString(),

                      label:
                          "DELETED",

                      icon:
                          Icons
                              .delete_outline_rounded,

                      color:
                          _purple,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 42 * scale,
              ),

              /// ALL TIME
              Text(
                  "${_formatBytes(totalSavedBytes)} saved all-time",

                style: TextStyle(
                  color:
                      Colors.white,

                  fontSize:
                      24 * scale,

                  fontWeight:
                      FontWeight
                          .w600,

                  fontStyle:
                      FontStyle
                          .italic,
                ),
              ),

              const Spacer(),

              /// BUTTON
              SizedBox(
                width:
                    double.infinity,

                child: FilledButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) =>
                          route
                              .isFirst,
                    );
                  },

                  style:
                      FilledButton.styleFrom(
                    backgroundColor:
                        Colors.white
                            .withOpacity(
                              0.12,
                            ),

                    foregroundColor:
                        Colors.white,

                    padding:
                        EdgeInsets.symmetric(
                      vertical:
                          20 * scale,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        100,
                      ),
                    ),
                  ),

                  child: Text(
                    "Return Home",

                    style:
                        TextStyle(
                      fontSize:
                          20 * scale,

                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 30 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required double scale,
    required String number,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding:
          EdgeInsets.symmetric(
        vertical:
            26 * scale,
      ),

      decoration: BoxDecoration(
        color:
            color.withOpacity(
          0.12,
        ),

        borderRadius:
            BorderRadius.circular(
          26 * scale,
        ),
      ),

      child: Column(
        children: [
          Text(
            number,

            style: TextStyle(
              color: color,

              fontSize:
                  62 * scale,

              fontWeight:
                  FontWeight.w900,

              height: 1,
            ),
          ),

          SizedBox(
            height: 10 * scale,
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            children: [
              Icon(
                icon,
                color: color,
                size: 26 * scale,
              ),

              SizedBox(
                width: 6 * scale,
              ),

              Text(
                label,

                style: TextStyle(
                  color: color,

                  fontSize:
                      22 * scale,

                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  String _formatBytes(
    int bytes,
  ) {
    if (bytes <= 0) {
      return "0 MB";
    }

    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;

    if (bytes >= gb) {
      return "${(bytes / gb).toStringAsFixed(1)} GB";
    }

    if (bytes >= mb) {
      return "${(bytes / mb).toStringAsFixed(1)} MB";
    }

    return "${(bytes / kb).toStringAsFixed(1)} KB";
  }
}