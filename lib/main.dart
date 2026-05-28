import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'Cubit/photo_cubit.dart';
import 'Tabs/mainscreen.dart';

import 'Widgets/streak/streak_scope.dart';
import 'Widgets/streak/streak_controller.dart';

/// 🔥 GLOBAL RouteObserver (PHẢI 1 INSTANCE DUY NHẤT)
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(
    StreakScope(
      controller: StreakController(),
      child: BlocProvider(
        create: (_) => PhotoCubit(),
        child: const PhotoApp(),
      ),
    ),
  );
}

class PhotoApp extends StatelessWidget {
  const PhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PhotoApp',

      /// 🔥 GẮN OBSERVER Ở ĐÂY
      navigatorObservers: [routeObserver],

      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF6F6F8),
      ),

      home: const MainScreen(),
    );
  }
}