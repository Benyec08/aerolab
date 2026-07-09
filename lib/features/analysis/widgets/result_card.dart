import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String value;

  const ResultCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 14),
            ),

            const SizedBox(height: 18),

            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
