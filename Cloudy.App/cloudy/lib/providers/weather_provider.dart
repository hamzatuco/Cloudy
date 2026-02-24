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
            error: 'Unable to fetch weather data for $city',
          );
        }
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
