class ForecastData {
  String? cod;
  double? message;
  int? cnt;
  List<DailyForecast>? list;
  ForecastCity? city;

  ForecastData({this.cod, this.message, this.cnt, this.list, this.city});

  ForecastData.fromJson(Map<String, dynamic> json) {
    cod = json['cod']?.toString();
    message = (json['message'] as num?)?.toDouble();
    cnt = json['cnt'];
    if (json['list'] != null) {
      list = <DailyForecast>[];
      json['list'].forEach((v) {
        list!.add(DailyForecast.fromJson(v));
      });
    }
    city = json['city'] != null
        ? ForecastCity.fromJson(json['city'])
        : null;
  }

  @override
  String toString() {
    return 'ForecastData(city: ${city?.name}, cnt: $cnt, days: ${list?.length})';
  }
}

class DailyForecast {
  int? dt;
  int? sunrise;
  int? sunset;
  DailyTemp? temp;
  DailyFeelsLike? feelsLike;
  int? pressure;
  int? humidity;
  List<DailyWeather>? weather;
  double? speed;
  int? deg;
  double? gust;
  int? clouds;
  double? pop;
  double? rain;
  double? snow;

  DailyForecast({
    this.dt,
    this.sunrise,
    this.sunset,
    this.temp,
    this.feelsLike,
    this.pressure,
    this.humidity,
    this.weather,
    this.speed,
    this.deg,
    this.gust,
    this.clouds,
    this.pop,
    this.rain,
    this.snow,
  });

  DailyForecast.fromJson(Map<String, dynamic> json) {
    dt = json['dt'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
    temp = json['temp'] != null ? DailyTemp.fromJson(json['temp']) : null;
    feelsLike = json['feels_like'] != null
        ? DailyFeelsLike.fromJson(json['feels_like'])
        : null;
    pressure = json['pressure'];
    humidity = json['humidity'];
    if (json['weather'] != null) {
      weather = <DailyWeather>[];
      json['weather'].forEach((v) {
        weather!.add(DailyWeather.fromJson(v));
      });
    }
    speed = (json['speed'] as num?)?.toDouble();
    deg = json['deg'];
    gust = (json['gust'] as num?)?.toDouble();
    clouds = json['clouds'];
    pop = (json['pop'] as num?)?.toDouble();
    rain = (json['rain'] as num?)?.toDouble();
    snow = (json['snow'] as num?)?.toDouble();
  }

  @override
  String toString() {
    return 'DailyForecast(dt: $dt, temp: ${temp?.day}, weather: ${weather?.first.main})';
  }
}

class DailyTemp {
  double? day;
  double? min;
  double? max;
  double? night;
  double? eve;
  double? morn;

  DailyTemp({this.day, this.min, this.max, this.night, this.eve, this.morn});

  DailyTemp.fromJson(Map<String, dynamic> json) {
    day = (json['day'] as num?)?.toDouble();
    min = (json['min'] as num?)?.toDouble();
    max = (json['max'] as num?)?.toDouble();
    night = (json['night'] as num?)?.toDouble();
    eve = (json['eve'] as num?)?.toDouble();
    morn = (json['morn'] as num?)?.toDouble();
  }
}

class DailyFeelsLike {
  double? day;
  double? night;
  double? eve;
  double? morn;

  DailyFeelsLike({this.day, this.night, this.eve, this.morn});

  DailyFeelsLike.fromJson(Map<String, dynamic> json) {
    day = (json['day'] as num?)?.toDouble();
    night = (json['night'] as num?)?.toDouble();
    eve = (json['eve'] as num?)?.toDouble();
    morn = (json['morn'] as num?)?.toDouble();
  }
}

class DailyWeather {
  int? id;
  String? main;
  String? description;
  String? icon;

  DailyWeather({this.id, this.main, this.description, this.icon});

  DailyWeather.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    main = json['main'];
    description = json['description'];
    icon = json['icon'];
  }
}

class ForecastCity {
  int? id;
  String? name;
  ForecastCoord? coord;
  String? country;
  int? population;
  int? timezone;

  ForecastCity({
    this.id,
    this.name,
    this.coord,
    this.country,
    this.population,
    this.timezone,
  });

  ForecastCity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    coord = json['coord'] != null
        ? ForecastCoord.fromJson(json['coord'])
        : null;
    country = json['country'];
    population = json['population'];
    timezone = json['timezone'];
  }
}

class ForecastCoord {
  double? lat;
  double? lon;

  ForecastCoord({this.lat, this.lon});

  ForecastCoord.fromJson(Map<String, dynamic> json) {
    lat = (json['lat'] as num?)?.toDouble();
    lon = (json['lon'] as num?)?.toDouble();
  }
}
