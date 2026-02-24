import 'package:equatable/equatable.dart';
import 'package:cloudy/models/weather_data.dart';

enum WeatherStatus { initial, loading, success, failure }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherData? data;
  final String error;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.data,
    this.error = '',
  });

  @override
  List<Object?> get props => [status, data, error];

  @override
  String toString() {
    return 'WeatherState{status: $status, data: $data, error: $error}';
  }

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherData? data,
    String? error,
  }) {
    return WeatherState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}
