import 'package:aerolab/features/analysis/services/wind_system_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = WindSystemService();

  group('WindSystemService', () {
    test('sakin havada rüzgâr bileşenleri sıfır olmalıdır', () {
      final result = service.calculate(
        windSpeedKmh: 35.0,
        windDirection: 'Sakin',
        commandedAirspeedMs: 20.0,
      );

      expect(result.windSpeedKmh, 0.0);
      expect(result.windSpeedMs, 0.0);
      expect(result.headwindComponentMs, 0.0);
      expect(result.tailwindComponentMs, 0.0);
      expect(result.crosswindComponentMs, 0.0);
      expect(result.effectiveAirspeedMs, 20.0);
      expect(result.estimatedGroundSpeedMs, 20.0);
      expect(result.windIntensityStatus, 'Sakin');
      expect(result.windSafetyStatus, 'Güvenli - sakin hava');
      expect(result.isWindWithinSupportedLimits, isTrue);
    });

    test('karşıdan rüzgâr headwind bileşenine dönüştürülmelidir', () {
      final result = service.calculate(
        windSpeedKmh: 36.0,
        windDirection: 'Karşıdan',
        commandedAirspeedMs: 20.0,
      );

      expect(result.windSpeedMs, closeTo(10.0, 1e-9));
      expect(result.headwindComponentMs, closeTo(10.0, 1e-9));
      expect(result.tailwindComponentMs, 0.0);
      expect(result.crosswindComponentMs, 0.0);
      expect(result.effectiveAirspeedMs, closeTo(30.0, 1e-9));
      expect(result.estimatedGroundSpeedMs, closeTo(10.0, 1e-9));
    });

    test('arkadan rüzgâr tailwind bileşenine dönüştürülmelidir', () {
      final result = service.calculate(
        windSpeedKmh: 18.0,
        windDirection: 'Arkadan',
        commandedAirspeedMs: 20.0,
      );

      expect(result.windSpeedMs, closeTo(5.0, 1e-9));
      expect(result.headwindComponentMs, 0.0);
      expect(result.tailwindComponentMs, closeTo(5.0, 1e-9));
      expect(result.effectiveAirspeedMs, closeTo(15.0, 1e-9));
      expect(result.estimatedGroundSpeedMs, closeTo(25.0, 1e-9));
    });

    test('soldan çapraz rüzgâr doğru yön ve bileşen üretmelidir', () {
      final result = service.calculate(
        windSpeedKmh: 28.8,
        windDirection: 'Soldan',
        commandedAirspeedMs: 20.0,
      );

      expect(result.crosswindComponentMs, closeTo(8.0, 1e-9));
      expect(result.crosswindDirection, 'Soldan');
      expect(result.headwindComponentMs, 0.0);
      expect(result.tailwindComponentMs, 0.0);
      expect(result.effectiveAirspeedMs, 20.0);
      expect(result.estimatedGroundSpeedMs, 20.0);
    });

    test('yön değeri büyük küçük harf farkı olmadan normalize edilmelidir', () {
      final result = service.calculate(
        windSpeedKmh: 10.0,
        windDirection: '  sağdan  ',
        commandedAirspeedMs: 20.0,
      );

      expect(result.windDirection, 'Sağdan');
      expect(result.crosswindDirection, 'Sağdan');
      expect(result.crosswindComponentMs, closeTo(10.0 / 3.6, 1e-9));
    });

    test(
      'çok güçlü arkadan rüzgâr etkin hava hızını güvenli alt sınıra sıkıştırmalıdır',
      () {
        final result = service.calculate(
          windSpeedKmh: 72.0,
          windDirection: 'Arkadan',
          commandedAirspeedMs: 10.0,
        );

        expect(result.effectiveAirspeedMs, 0.1);
        expect(result.estimatedGroundSpeedMs, 30.0);
        expect(result.windSafetyStatus, 'Kritik - analiz sınırı aşıldı');
        expect(result.isWindWithinSupportedLimits, isFalse);
      },
    );

    test('geçersiz girişler ArgumentError üretmelidir', () {
      expect(
        () => service.calculate(
          windSpeedKmh: -1.0,
          windDirection: 'Karşıdan',
          commandedAirspeedMs: 20.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          windSpeedKmh: 10.0,
          windDirection: 'Çapraz',
          commandedAirspeedMs: 20.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => service.calculate(
          windSpeedKmh: 10.0,
          windDirection: 'Karşıdan',
          commandedAirspeedMs: 0.0,
        ),
        throwsArgumentError,
      );
    });
  });
}
