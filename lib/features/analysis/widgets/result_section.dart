import 'package:flutter/material.dart';
import 'widgets/result_section.dart';

class ResultSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ResultSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123B7A),
            ),
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }
}
