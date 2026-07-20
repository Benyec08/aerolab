/*
====================================================================

Project
AeroLab

Sprint
4

Module
Reusable Widgets

File
analysis_section.dart

Description

Bu widget AeroLab içerisindeki tüm form bölümlerini
tek tip görünümde oluşturmak için geliştirilmiştir.

Örnek:

Genel Bilgiler

Motor

Batarya

Aerodinamik

Çevre

Bu sayede uygulamanın tamamında aynı tasarım dili korunur.

====================================================================
*/

import 'package:flutter/material.dart';

class AnalysisSection extends StatelessWidget {
  final String title;
  final Widget child;

  const AnalysisSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B3D91),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD9E2EC)),
          ),
          child: child,
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
