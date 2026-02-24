import 'package:flutter/foundation.dart';
import 'package:cloudy/models/weather_data.dart';
import 'package:cloudy/models/forecast_data.dart';
import 'package:cloudy/models/hourly_forecast_data.dart';
import 'package:cloudy/repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();
  WeatherState _state = const WeatherState();

  WeatherState get state => _state;

  Future<void> fetchWeather(String city) async {
    _state = _state.copyWith(
      status: WeatherStatus.loading,
      city: city,
    );
    notifyListeners();

    try {
      final result = await _repository.apiCall(city);

      if (result != null) {
        final current = result['current'] as WeatherData?;
        final daily = result['daily'] as ForecastData?;
        final hourly = result['hourly'] as HourlyForecastData?;

        if (current != null) {
          _state = _state.copyWith(
            status: WeatherStatus.success,
            data: current,
            forecast: daily,
            hourlyForecast: hourly,
            error: '',
          );
        } else {
          _state = _state.copyWith(
            status: WeatherStatus.failure,
            error: 'Got response but no weather data for "$city". Check API key or city name.',
          );
        }
      } else {
        _state = _state.copyWith(
          status: WeatherStatus.failure,
          error: 'Network error — check internet connection. City: $city',
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        status: WeatherStatus.failure,
        error: 'Exception: ${e.toString()}',
      );
    }

    notifyListeners();
  }

  Future<String?> fetchWeatherByCoords({
    required double lat,
    required double lon,
  }) async {
    debugPrint('🌍 [fetchWeatherByCoords] START - lat: $lat, lon: $lon');
    _state = _state.copyWith(
      status: WeatherStatus.loading,
      city: '',
    );
    notifyListeners();
    debugPrint('🌍 [fetchWeatherByCoords] Sent LOADING state');

    try {
      debugPrint('🌍 [fetchWeatherByCoords] Calling API...');
      final result = await _repository.apiCallByCoords(lat: lat, lon: lon);
      debugPrint('🌍 [fetchWeatherByCoords] API returned');

      if (result != null) {
        final current = result['current'] as WeatherData?;
        final daily = result['daily'] as ForecastData?;
        final hourly = result['hourly'] as HourlyForecastData?;
        debugPrint('🌍 [fetchWeatherByCoords] Parsed: current=${current?.name}, daily=${daily?.list?.length}, hourly=${hourly?.list?.length}');

        if (current != null) {
          final cityName = (current.name ?? '').trim();
          debugPrint('🌍 [fetchWeatherByCoords] Setting SUCCESS state for: $cityName');
          _state = _state.copyWith(
            status: WeatherStatus.success,
            data: current,
            forecast: daily,
            hourlyForecast: hourly,
            error: '',
            city: cityName,
          );
          debugPrint('🌍 [fetchWeatherByCoords] Calling notifyListeners()...');
          notifyListeners();
          debugPrint('🌍 [fetchWeatherByCoords] notifyListeners() DONE - returning city: $cityName');
          return cityName.isEmpty ? null : cityName;
        }
      }

      _state = _state.copyWith(
        status: WeatherStatus.failure,
        error: 'Unable to fetch weather data for your location',
      );
    } catch (e) {
      _state = _state.copyWith(
        status: WeatherStatus.failure,
        error: 'Error: ${e.toString()}',
      );
    }

    notifyListeners();
    return null;
  }

  Future<void> retry() async {
    if (_state.city.isNotEmpty) {
      await fetchWeather(_state.city);
    }
  }

  void reset() {
    _state = const WeatherState();
    notifyListeners();
  }
}
