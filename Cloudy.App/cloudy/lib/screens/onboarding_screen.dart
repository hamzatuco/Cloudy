import 'package:cloudy/providers/weather_provider.dart';
import 'package:cloudy/providers/weather_state.dart';
import 'package:cloudy/screens/city_search_dialog.dart';
import 'package:cloudy/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function(String city) onCompleteWithCity;

  const OnboardingScreen({
    super.key,
    required this.onCompleteWithCity,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _defaultCity = 'Sarajevo';

  bool _busy = false;
  String _selectedCity = _defaultCity;
  String? _error;

  Future<void> _setBusy(Future<void> Function() work) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await work();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Position?> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Location services are off. Turn them on or pick a city manually.';
      });
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _error =
            'Location permission was denied. Pick a city manually (this screen is only shown on first launch).';
      });
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    await _setBusy(() async {
      debugPrint('📍 [_useCurrentLocation] START');
      final pos = await _getPosition();
      if (pos == null) {
        debugPrint('📍 [_useCurrentLocation] Position is null, returning');
        return;
      }
      if (!mounted) {
        debugPrint('📍 [_useCurrentLocation] Not mounted, returning');
        return;
      }

      debugPrint('📍 [_useCurrentLocation] Got position: ${pos.latitude}, ${pos.longitude}');
      final provider = context.read<WeatherProvider>();
      debugPrint('📍 [_useCurrentLocation] Calling fetchWeatherByCoords...');
      final cityName = await provider.fetchWeatherByCoords(
        lat: pos.latitude,
        lon: pos.longitude,
      );
      debugPrint('📍 [_useCurrentLocation] fetchWeatherByCoords returned: $cityName');

      if (cityName == null || cityName.trim().isEmpty) {
        debugPrint('📍 [_useCurrentLocation] City name is empty');
        setState(() {
          _error = 'Couldn\'t detect your city. Pick a city manually.';
        });
        return;
      }
      debugPrint('📍 [_useCurrentLocation] Calling onCompleteWithCity($cityName)');
      await widget.onCompleteWithCity(cityName);
      debugPrint('📍 [_useCurrentLocation] onCompleteWithCity DONE');
    });
  }

  Future<void> _confirmCity() async {
    await _setBusy(() async {
      final city = _selectedCity.trim();
      if (city.isEmpty) return;

      final provider = context.read<WeatherProvider>();
      await provider.fetchWeather(city);

      final ok = provider.state.status == WeatherStatus.success;
      if (!ok) {
        setState(() => _error =
            provider.state.error.isEmpty ? 'Couldn’t load forecast.' : provider.state.error);
        return;
      }

      await widget.onCompleteWithCity(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2FA6FF), Color(0xFF0B1D4D)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassCard(
                    borderRadius: 28,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: SizedBox(
                            height: 140,
                            width: 140,
                            child: Lottie.asset(
                              'assets/cloudy_day.json',
                              repeat: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add your first city',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This screen is only shown during the initial setup.\nYou can allow location or pick a city manually.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        FilledButton(
                          onPressed: _busy ? null : _useCurrentLocation,
                          child: _busy
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Allow location'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _busy
                              ? null
                              : () async {
                                  final city = await showDialog<String?>(
                                    context: context,
                                    builder: (context) => const CitySearchDialog(),
                                  );
                                  if (city != null && city.isNotEmpty) {
                                    setState(() => _selectedCity = city);
                                    await _confirmCity();
                                  }
                                },
                          child: const Text('Pick a city manually'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

