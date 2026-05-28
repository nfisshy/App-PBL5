import 'package:flutter/material.dart';

class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7D2CE),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              color: const Color(0xFFE5A678),
              child: const Center(
                child: Text(
                  "Recents",
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(
                            text: "Recents ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                "is like an inbox\nfor your camera roll.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "it will display photos\nfrom the past 5 days\nthat you haven’t\nreviewed yet.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.3,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 55),

                    const Text(
                      "OK, that’s it.\nhappy swiping!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        height: 1.3,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 45),

                    Icon(
                      Icons.inbox_outlined,
                      size: 58,
                      color: const Color(0xFFE5A678),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
              child: SizedBox(
                height: 115,
                child: ElevatedButton(
                  onPressed: () {Navigator.pop(context);},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF74E0A0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(38),
                    ),
                  ),
                  child: const Text(
                    "Return Home",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}