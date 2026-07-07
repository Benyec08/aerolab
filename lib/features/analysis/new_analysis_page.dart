import 'package:flutter/material.dart';

class NewAnalysisPage extends StatelessWidget {
  const NewAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F7FB),
      body: Center(
        child: Text(
          'Yeni Analiz Sayfası',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}