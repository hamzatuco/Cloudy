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
  static void getGeoData(String city) async {
    
    String url = baseUrl + geoDirect + '?q=${city}&limit=5&appid=' + apiKey;
    var res = await http.get(Uri.parse(url));
    
    GeoData geoData = GeoData.fromJson(jsonDecode( res.body));


    print(geoData.toString());
    print(url);
  }


  static void getWeatherData() async {
  
    
    String url = baseUrl + "/data/2.5/weather?lat=43.8519774&lon=18.3866868&units=metric&appid=" + apiKey;
    var res = await http.get(Uri.parse(url));
    WeatherData weatherData = WeatherData.fromJson(jsonDecode(res.body));
    // print(res.body);
    print(weatherData.toString());
    print(res.body);
  }

}