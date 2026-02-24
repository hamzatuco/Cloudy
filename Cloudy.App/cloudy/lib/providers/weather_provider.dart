import 'package:flutter/foundation.dart';
import 'package:cloudy/models/weather_data.dart';
import 'package:cloudy/repositories/weather_repository.dart';
import 'weather_state.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();
  WeatherState _state = const WeatherState();

  WeatherState get state => _state;

  Future<void> fetchWeather(String city) async {
    _state = _state.copyWith(status: WeatherStatus.loading);
    notifyListeners();

    try {
      final WeatherData? weatherData = await _repository.apiCall(city);

      if (weatherData != null) {
        _state = _state.copyWith(
          status: WeatherStatus.success,
          data: weatherData,
          error: '',
        );
      } else {
        _state = _state.copyWith(
          status: WeatherStatus.failure,
          error: 'Unable to fetch weather data for $city',
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        status: WeatherStatus.failure,
        error: 'Error: ${e.toString()}',
      );
    }

    notifyListeners();
  }

  Future<void> retry(String city) async {
    await fetchWeather(city);
  }

  void reset() {
    _state = const WeatherState();
    notifyListeners();
  }
}
