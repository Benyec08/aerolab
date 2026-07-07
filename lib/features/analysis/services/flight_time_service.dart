/*
====================================================================

Project
AeroLab

Module
Aerodynamics Engine

File
flight_time_service.dart

Description

Bu servis batarya kapasitesi, voltaj ve tahmini güç tüketimine göre
yaklaşık uçuş süresi hesabı yapar.

Bu hesap şimdilik basitleştirilmiştir.
İleride motor verimi, pervane verimi ve batarya deşarj eğrisi eklenecektir.

====================================================================
*/

class FlightTimeService {
  double calculateMinutes({
    required double batteryCapacityMah,
    required double batteryVoltageV,
    required double averagePowerConsumptionW,
  }) {
    //--------------------------------------------------------------
    // mAh -> Ah dönüşümü
    //--------------------------------------------------------------

    final batteryCapacityAh = batteryCapacityMah / 1000;

    //--------------------------------------------------------------
    // Batarya enerjisi
    //
    // Energy(Wh) = Capacity(Ah) × Voltage(V)
    //--------------------------------------------------------------

    final energyWh = batteryCapacityAh * batteryVoltageV;

    //--------------------------------------------------------------
    // Uçuş süresi
    //
    // Time(hours) = Energy(Wh) / Power(W)
    //--------------------------------------------------------------

    final flightTimeHours = energyWh / averagePowerConsumptionW;

    //--------------------------------------------------------------
    // Saat -> dakika dönüşümü
    //--------------------------------------------------------------

    return flightTimeHours * 60;
  }
}