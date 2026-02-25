class HourlyForecastData {
  String? cod;
  int? message;
  int? cnt;
  List<HourlyItem>? list;

  HourlyForecastData({this.cod, this.message, this.cnt, this.list});

  HourlyForecastData.fromJson(Map<String, dynamic> json) {
    cod = json['cod']?.toString();
    message = json['message'];
    cnt = json['cnt'];
    if (json['list'] != null) {
      list = <HourlyItem>[];
      json['list'].forEach((v) {
        list!.add(HourlyItem.fromJson(v));
      });
    }
  }
}

class HourlyItem {
  int? dt;
  HourlyMain? main;
  List<HourlyWeather>? weather;
  HourlyWind? wind;
  int? visibility;
  double? pop;
  String? dtTxt;

  HourlyItem({
    this.dt,
    this.main,
    this.weather,
    this.wind,
    this.visibility,
    this.pop,
    this.dtTxt,
  });

  HourlyItem.fromJson(Map<String, dynamic> json) {
    dt = json['dt'];
    main = json['main'] != null ? HourlyMain.fromJson(json['main']) : null;
    if (json['weather'] != null) {
      weather = <HourlyWeather>[];
      json['weather'].forEach((v) {
        weather!.add(HourlyWeather.fromJson(v));
      });
    }
    wind = json['wind'] != null ? HourlyWind.fromJson(json['wind']) : null;
    visibility = json['visibility'];
    pop = (json['pop'] as num?)?.toDouble();
    dtTxt = json['dt_txt'];
  }
}

class HourlyMain {
  double? temp;
  double? feelsLike;
  double? tempMin;
  double? tempMax;
  int? pressure;
  int? humidity;

  HourlyMain({
    this.temp,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.humidity,
  });

  HourlyMain.fromJson(Map<String, dynamic> json) {
    temp = (json['temp'] as num?)?.toDouble();
    feelsLike = (json['feels_like'] as num?)?.toDouble();
    tempMin = (json['temp_min'] as num?)?.toDouble();
    tempMax = (json['temp_max'] as num?)?.toDouble();
    pressure = json['pressure'];
    humidity = json['humidity'];
  }
}

class HourlyWeather {
  int? id;
  String? main;
  String? description;
  String? icon;

  HourlyWeather({this.id, this.main, this.description, this.icon});

  HourlyWeather.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    main = json['main'];
    description = json['description'];
    icon = json['icon'];
  }
}

class HourlyWind {
  double? speed;
  int? deg;
  double? gust;

  HourlyWind({this.speed, this.deg, this.gust});

  HourlyWind.fromJson(Map<String, dynamic> json) {
    speed = (json['speed'] as num?)?.toDouble();
    deg = json['deg'];
    gust = (json['gust'] as num?)?.toDouble();
  }
}
