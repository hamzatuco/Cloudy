import 'dart:async';
import 'dart:ui';
import 'city_search_service.dart';

class CitySearchStateService {
  final _searchService = CitySearchService();

  // State variables
  List<CityData> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  // Getters
  List<CityData> get results => _results;
  bool get isSearching => _isSearching;

  // Callbacks for UI updates
  final List<VoidCallback> _listeners = [];

  /// Add listener for state changes
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of state changes
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Pre-load cities in background
  Future<void> initialize() async {
    try {
      await _searchService.loadCities();
      print('📍 [CitySearchStateService] Initialized');
    } catch (e) {
      print('❌ [CitySearchStateService] Initialization error: $e');
    }
  }

  /// Handle search input with debounce
  Future<void> onSearchChanged(String query) async {
    _lastQuery = query;

    if (query.isEmpty) {
      _results = [];
      _isSearching = false;
      _notifyListeners();
      return;
    }

    _isSearching = true;
    _notifyListeners();

    try {
      // searchCities() handles debounce internally
      final results = await _searchService.searchCities(query);

      // Only update if the query hasn't changed during the search
      if (_lastQuery == query) {
        _results = results;
        _isSearching = false;
        _notifyListeners();
      }
    } catch (e) {
      print('❌ [CitySearchStateService] Search error: $e');
      if (_lastQuery == query) {
        _isSearching = false;
        _notifyListeners();
      }
    }
  }

  /// Clear all state
  void reset() {
    _results = [];
    _isSearching = false;
    _lastQuery = '';
    _notifyListeners();
  }

  /// Dispose and cleanup
  void dispose() {
    _listeners.clear();
    _searchService.clearCache();
  }
}
