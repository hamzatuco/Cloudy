class GeoData {
  final String? name;
  final LocalNames? localNames;
  final double? lat;
  final double? lon;
  final String? country;
  final String? state;

  GeoData({
    this.name,
    this.localNames,
    this.lat,
    this.lon,
    this.country,
    this.state,
  });

  factory GeoData.fromJson(Map<String, dynamic> json) {
    return GeoData(
      name: json['name'],
      localNames: json['local_names'] != null
          ? LocalNames.fromJson(json['local_names'])
          : null,
      lat: json['lat'],
      lon: json['lon'],
      country: json['country'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'local_names': localNames?.toJson(),
      'lat': lat,
      'lon': lon,
      'country': country,
      'state': state,
    };
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
