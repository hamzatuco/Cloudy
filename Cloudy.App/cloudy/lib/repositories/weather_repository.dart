import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/constants/api_endpoints.dart';

class WeatherRepository {
  static void getGeoData() async {
    final apiKey = kIsWeb 
        ? '05f29dd2f3a04ab697ac038251b8422a' 
        : (dotenv.env['WEATHER_API_KEY'] ?? '');
    
    String url = baseUrl + geoDirect + '?q=Sarajevo&limit=5&appid=' + apiKey;
    var res = await http.get(Uri.parse(url));
    
    print(res.body);
    print(url);
  }
}