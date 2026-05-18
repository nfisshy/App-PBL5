import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Cubit/place_cubit.dart';
import '../State/place_state.dart';

class PlacesScreen
    extends StatelessWidget {
  const PlacesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => PlacesCubit()
            ..loadPlaces(),

      child: Scaffold(
        backgroundColor:
            const Color(0xFFF7F7F7),

        body: SafeArea(
          child: BlocBuilder<
            PlacesCubit,
            PlacesState
          >(
            builder: (
              context,
              state,
            ) {
              /// LOADING
              if (state.isLoading) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              /// FAIL
              if (state.loadFail) {
                return const Center(
                  child: Text(
                    "Failed to load places",
                  ),
                );
              }

              return Column(
                children: [
                  /// TOP BAR
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),

                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },

                          child: Container(
                            width: 58,
                            height: 58,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.grey
                                      .withOpacity(
                                0.12,
                              ),

                              shape:
                                  BoxShape
                                      .circle,
                            ),

                            child: const Icon(
                              Icons
                                  .arrow_back_ios_new_rounded,
                              color:
                                  Colors.black,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Center(
                            child: Text(
                              "PLACES",

                              style:
                                  TextStyle(
                                fontSize:
                                    30,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    -1.5,
                              ),
                            ),
                          ),
                        ),

                        Container(
                          width: 58,
                          height: 58,

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.grey
                                    .withOpacity(
                              0.12,
                            ),

                            shape:
                                BoxShape
                                    .circle,
                          ),

                          child: const Icon(
                            Icons
                                .tune_rounded,
                            color:
                                Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  /// LIST
                  Expanded(
                    child: ListView.builder(
                      physics:
                          const BouncingScrollPhysics(),

                      itemCount:
                          state.places.length,

                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final place =
                            state
                                .places[index];

                        return Container(
                          height: 128,

                          margin:
                              const EdgeInsets.only(
                            bottom: 1,
                          ),

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                36,
                          ),

                          alignment:
                              Alignment
                                  .centerLeft,

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF4F4F4,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                  0.04,
                                ),

                                blurRadius:
                                    18,

                                offset:
                                    const Offset(
                                  0,
                                  8,
                                ),
                              ),
                            ],
                          ),

                          child: Text(
                            place,

                            style:
                                const TextStyle(
                              fontSize: 44,
                              fontWeight:
                                  FontWeight
                                      .w900,

                              letterSpacing:
                                  -2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}