import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final String? description;
  final Color? color;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    this.description,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = color ?? const Color(0xFFD9E2EC);
    final bool hasDescription =
        description != null && description!.trim().isNotEmpty;

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: color == null
              ? const Color(0xFFD9E2EC)
              : cardColor.withValues(alpha: 0.45),
          width: 1.3,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(hasDescription ? 18 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 14),
            ),
            SizedBox(height: hasDescription ? 10 : 18),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color ?? const Color(0xFF102A43),
              ),
            ),
            if (hasDescription) ...[
              const SizedBox(height: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: Color(0xFF627D98),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
