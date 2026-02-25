import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class CityData {
  final String country;
  final String name;
  final double lat;
  final double lng;

  CityData({
    required this.country,
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      country: json['country'] ?? '',
      name: json['name'] ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
    );
  }
}

class CitySearchService {
  static final CitySearchService _instance = CitySearchService._internal();

  factory CitySearchService() {
    return _instance;
  }

  CitySearchService._internal();

  List<CityData>? _cachedCities;
  Timer? _debounceTimer;

  /// Lazy load cities from JSON asset
  Future<void> loadCities() async {
    if (_cachedCities != null) return; // Already loaded

    try {
      final jsonString = await rootBundle.loadString('assets/world_cities.json');
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      _cachedCities = jsonData
          .map((item) => CityData.fromJson(item as Map<String, dynamic>))
          .toList();
      print('📍 [CitySearchService] Loaded ${_cachedCities!.length} cities');
    } catch (e) {
      print('❌ [CitySearchService] Error loading cities: $e');
      rethrow;
    }
  }

  /// Search cities with optional fuzzy matching
  /// Returns results with debounce applied
  Future<List<CityData>> searchCities(
    String query, {
    Duration debounceDelay = const Duration(milliseconds: 400),
  }) async {
    // Cancel previous search
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      return [];
    }

    // Wait for debounce
    final completer = Completer<List<CityData>>();
    _debounceTimer = Timer(debounceDelay, () async {
      await loadCities();
      final results = _performSearch(query);
      completer.complete(results);
    });

    return completer.future;
  }

  /// Synchronous search (after cities are loaded)
  List<CityData> _performSearch(String query) {
    if (_cachedCities == null || query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase().trim();
    final results = <CityData>[];

    for (final city in _cachedCities!) {
      final cityName = city.name.toLowerCase();
      
      // Exact prefix match (highest priority)
      if (cityName.startsWith(lowerQuery)) {
        results.add(city);
      }
      // Contains match (lower priority)
      else if (cityName.contains(lowerQuery)) {
        results.add(city);
      }
    }

    // Sort: prefix matches first, then by city name length
    results.sort((a, b) {
      final aStartsWith = a.name.toLowerCase().startsWith(lowerQuery);
      final bStartsWith = b.name.toLowerCase().startsWith(lowerQuery);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return a.name.length.compareTo(b.name.length);
    });

    return results.take(15).toList(); // Limit to 15 results
  }

  /// Get coordinates for a city name
  Future<({double lat, double lng})?> getCityCoords(String cityName) async {
    await loadCities();
    try {
      final city = _cachedCities?.firstWhere(
        (c) => c.name.toLowerCase().trim() == cityName.toLowerCase().trim(),
        orElse: () => CityData(
          country: '',
          name: '',
          lat: 0.0,
          lng: 0.0,
        ),
      );

      if (city != null && city.name.isNotEmpty) {
        return (lat: city.lat, lng: city.lng);
      }
      return null;
    } catch (e) {
      print('❌ [CitySearchService] Error getting coordinates: $e');
      return null;
    }
  }

  /// Convert country code to flag emoji
  /// E.g., "BA" → 🇧🇦, "US" → 🇺🇸
  static String countryCodeToFlag(String countryCode) {
    if (countryCode.isEmpty || countryCode.length != 2) {
      return '🌍';
    }

    final code = countryCode.toUpperCase();
    final flag = String.fromCharCode(
      0x1F1E6 + code.codeUnitAt(0) - 'A'.codeUnitAt(0),
    ) +
        String.fromCharCode(
          0x1F1E6 + code.codeUnitAt(1) - 'A'.codeUnitAt(0),
        );

    return flag;
  }

  /// Clear cache (useful for testing or memory management)
  void clearCache() {
    _cachedCities = null;
    _debounceTimer?.cancel();
  }
}
