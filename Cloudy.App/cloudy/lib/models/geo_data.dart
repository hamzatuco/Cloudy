class GeoData {
  String? name;
  LocalNames? localNames;
  double? lat;
  double? lon;
  String? country;
  String? state;


@override
  String toString() {
    return 'GeoData{name: $name, lat: $lat, lon: $lon, country: $country, state: $state}';
  }
  GeoData(
      {this.name,
      this.localNames,
      this.lat,
      this.lon,
      this.country,
      this.state});

  GeoData.fromJson(List<dynamic> json) {
    name = json[0]['name'];
    lat = (json[0]['lat'] as num?)?.toDouble();
    lon = (json[0]['lon'] as num?)?.toDouble();
    country = json[0]['country'];
    state = json[0]['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.localNames != null) {
      data['local_names'] = this.localNames!.toJson();
    }
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['country'] = this.country;
    data['state'] = this.state;
    return data;
  }
}

class LocalNames {
  final String? en;
  final String? de;
  final String? fr;
  final String? es;
  final String? it;
  final String? pl;
  final String? ru;
  final String? ja;
  final String? zh;
  final String? bs;
  final String? hr;
  final String? sr;
  final String? ar;

  LocalNames({
    this.en,
    this.de,
    this.fr,
    this.es,
    this.it,
    this.pl,
    this.ru,
    this.ja,
    this.zh,
    this.bs,
    this.hr,
    this.sr,
    this.ar,
  });

  factory LocalNames.fromJson(Map<String, dynamic> json) {
    return LocalNames(
      en: json['en'],
      de: json['de'],
      fr: json['fr'],
      es: json['es'],
      it: json['it'],
      pl: json['pl'],
      ru: json['ru'],
      ja: json['ja'],
      zh: json['zh'],
      bs: json['bs'],
      hr: json['hr'],
      sr: json['sr'],
      ar: json['ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'de': de,
      'fr': fr,
      'es': es,
      'it': it,
      'pl': pl,
      'ru': ru,
      'ja': ja,
      'zh': zh,
      'bs': bs,
      'hr': hr,
      'sr': sr,
      'ar': ar,
    };
  }
}
