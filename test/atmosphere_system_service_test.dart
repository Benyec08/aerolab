import 'package:aerolab/features/analysis/services/atmosphere_system_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AtmosphereSystemService', () {
    final service = AtmosphereSystemService();

    test('deniz seviyesinde standart kuru atmosferi doğru hesaplar', () {
      final result = service.calculate(
        altitudeM: 0,
        temperatureC: 15,
        pressureHpa: 1013.25,
        relativeHumidityPercent: 0,
      );

      expect(result.isaTemperatureC, closeTo(15, 0.01));
      expect(result.isaPressureHpa, closeTo(1013.25, 0.02));
      expect(result.humidAirDensityKgM3, closeTo(1.225, 0.002));
      expect(result.densityAltitudeM, closeTo(0, 5));
      expect(result.atmosphereStatus, 'Normal Atmosfer');
    });

    test('nem arttığında aynı sıcaklık ve basınçta yoğunluk azalır', () {
      final dryResult = service.calculate(
        altitudeM: 0,
        temperatureC: 30,
        pressureHpa: 1013.25,
        relativeHumidityPercent: 0,
      );

      final humidResult = service.calculate(
        altitudeM: 0,
        temperatureC: 30,
        pressureHpa: 1013.25,
        relativeHumidityPercent: 100,
      );

      expect(
        humidResult.humidAirDensityKgM3,
        lessThan(dryResult.humidAirDensityKgM3),
      );
      expect(
        humidResult.densityAltitudeM,
        greaterThan(dryResult.densityAltitudeM),
      );
    });

    test('sıcak ve nemli koşulda yoğunluk irtifasını yükseltir', () {
      final result = service.calculate(
        altitudeM: 1500,
        temperatureC: 35,
        pressureHpa: 850,
        relativeHumidityPercent: 70,
      );

      expect(result.temperatureDeviationC, greaterThan(20));
      expect(result.densityAltitudeM, greaterThan(result.geometricAltitudeM));
      expect(result.densityAltitudeDifferenceM, greaterThan(1000));
      expect(
        result.atmosphereStatus,
        anyOf('Zorlu Atmosfer', 'Kritik Yoğunluk İrtifası'),
      );
    });

    test('geçersiz nem değerini reddeder', () {
      expect(
        () => service.calculate(
          altitudeM: 0,
          temperatureC: 15,
          pressureHpa: 1013.25,
          relativeHumidityPercent: 101,
        ),
        throwsArgumentError,
      );
    });

    test('desteklenen irtifa aralığı dışını reddeder', () {
      expect(
        () => service.calculate(
          altitudeM: 20001,
          temperatureC: -56.5,
          pressureHpa: 54.7,
          relativeHumidityPercent: 10,
        ),
        throwsArgumentError,
      );
    });
  });
}
