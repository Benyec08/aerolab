/*
====================================================================

Project
AeroLab

Module
Aerodynamics Engine

File
stall_service.dart

Description

Bu servis hava aracının Stall Speed (Kalkış / Düşüş Stall Hızı)
hesabını yapar.

Bu sürümde sadeleştirilmiş formül kullanılmaktadır.

Sprint 5'te gerçek aerodinamik hesaplama eklenecektir.

====================================================================
*/

import 'dart:math';

class StallService {

  double calculate({
    required double weightKg,
    required double wingAreaM2,
    required double airDensity,
    required double clMax,
  }) {

    //--------------------------------------------------------------
    // Kg -> Newton
    //--------------------------------------------------------------

    final weightNewton = weightKg * 9.81;

    //--------------------------------------------------------------
    // Stall Speed
    //
    // Vs = √((2W)/(ρSCLmax))
    //--------------------------------------------------------------

    final stallSpeed = sqrt(
      (2 * weightNewton) /
      (airDensity * wingAreaM2 * clMax),
    );

    return stallSpeed;
  }
}