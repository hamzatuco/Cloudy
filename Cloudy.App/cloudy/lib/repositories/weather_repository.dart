import 'dart:convert';

import 'package:cloudy/models/geo_data.dart';
import 'package:cloudy/models/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/api_endpoints.dart';

final apiKey = kIsWeb
    ? '05f29dd2f3a04ab697ac038251b8422a'
    : (dotenv.env['WEATHER_API_KEY'] ?? '');

class WeatherRepository {
  Future<GeoData?> getGeoData(String city) async {
    String url = '$baseUrl$geoDirect?q=${city}&limit=5&appid=$apiKey';

    try {
      var res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) {
        print('Error: ${res.statusCode}');
        return null;
      }

      GeoData geoData = GeoData.fromJson(jsonDecode(res.body));

      print(geoData.toString());
      print(url);
      return geoData;
    } catch (e) {
      print('Exception in getGeoData: $e');
      return null;
    }
  }

  Future<WeatherData?> getWeatherData(GeoData geoData) async {
    String url =
        baseUrl +
        "/data/2.5/weather?lat=${geoData.lat}&lon=${geoData.lon}&units=metric&appid=" +
        apiKey;

    try {
      var res = await http.get(Uri.parse(url));
      
      if (res.statusCode != 200) {
        print('Error: ${res.statusCode}');
        return null;
      }
      
      WeatherData weatherData = WeatherData.fromJson(jsonDecode(res.body));
      print(weatherData.toString());
      print(res.body);

      return weatherData;
    } catch (e) {
      print('Exception in getWeatherData: $e');
      return null;
    }
  }

  Future<WeatherData?> apiCall(String city) async {
    try {
      final GeoData? geoData = await getGeoData(city);
      if (geoData == null) return null;
      final WeatherData? weatherData = await getWeatherData(geoData);
      return weatherData;
    } catch (e) {
      print('Exception in apiCall: $e');
      return null;
    }
  }
}
