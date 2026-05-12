import 'package:flutter/material.dart';

/// Lưới icon placeholder — bạn thay asset / icon sau.
class AppIconPickerScreen extends StatelessWidget {
  const AppIconPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biểu tượng app')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            return Material(
              color: Colors.primaries[index % Colors.primaries.length]
                  .withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Icon(
                  Icons.widgets_outlined,
                  color: Colors
                      .primaries[index % Colors.primaries.length]
                      .shade700,
                  size: 36,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
