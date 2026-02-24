import 'package:equatable/equatable.dart';
import 'package:cloudy/models/weather_data.dart';
import 'package:cloudy/models/forecast_data.dart';
import 'package:cloudy/models/hourly_forecast_data.dart';

enum WeatherStatus { initial, loading, success, failure }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherData? data;
  final ForecastData? forecast;
  final HourlyForecastData? hourlyForecast;
  final String error;
  final String city;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.data,
    this.forecast,
    this.hourlyForecast,
    this.error = '',
    this.city = '',
  });

  @override
  List<Object?> get props => [status, data, forecast, hourlyForecast, error, city];

  @override
  String toString() {
    return 'WeatherState{status: $status, city: $city, data: $data, forecast: $forecast, error: $error}';
  }

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherData? data,
    ForecastData? forecast,
    HourlyForecastData? hourlyForecast,
    String? error,
    String? city,
  }) {
    return WeatherState(
      status: status ?? this.status,
      data: data ?? this.data,
      forecast: forecast ?? this.forecast,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      error: error ?? this.error,
      city: city ?? this.city,
    );
  }
}
