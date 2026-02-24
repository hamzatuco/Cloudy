import 'package:flutter_test/flutter_test.dart';
import 'package:cloudy/providers/weather_provider.dart';
import 'package:cloudy/providers/weather_state.dart';

void main() {
  group('WeatherProvider Tests', () {
    late WeatherProvider provider;

    setUp(() {
      provider = WeatherProvider();
    });

    test('Initial state je WeatherStatus.initial', () {
      expect(provider.state.status, WeatherStatus.initial);
      expect(provider.state.data, null);
      expect(provider.state.error, '');
    });

    test('fetchWeather promjena stanja na loading', () async {
      // Initial state
      expect(provider.state.status, WeatherStatus.initial);

      // Pokreni fetch (bez await, gledamo trenutni state)
      provider.fetchWeather('Mostar');
      
      // State bi trebao biti loading
      expect(provider.state.status, WeatherStatus.loading);
    });

    test('reset() resetira state na initial', () async {
      // Prvo promijeni state
      provider.fetchWeather('test').then((_) {
        // Reset
        provider.reset();
        
        // Provjeri da li je resetiran
        expect(provider.state.status, WeatherStatus.initial);
        expect(provider.state.data, null);
      });
    });

    test('copyWith na WeatherState radi ispravno', () {
      final originalState = provider.state;
      final newState = originalState.copyWith(
        status: WeatherStatus.failure,
        error: 'Test error',
      );

      expect(newState.status, WeatherStatus.failure);
      expect(newState.error, 'Test error');
      expect(newState.data, originalState.data);
    });
  });
}
