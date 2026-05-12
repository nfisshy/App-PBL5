import 'package:flutter/material.dart';

class WrappedScreen extends StatelessWidget {
  const WrappedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wrapped')),
      body: const SizedBox.expand(),
    );
  }
}
