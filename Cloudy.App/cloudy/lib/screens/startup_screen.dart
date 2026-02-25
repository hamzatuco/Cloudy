import 'package:cloudy/core/storage/app_storage.dart';
import 'package:cloudy/screens/home_screen.dart';
import 'package:cloudy/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool _loading = true;
  bool _showHome = false;
  String? _favoriteCity;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final hasOnboarded = await AppStorage.getHasOnboarded();
    final favoriteCity = await AppStorage.getFavoriteCity();

    if (hasOnboarded && favoriteCity != null) {
      _favoriteCity = favoriteCity;
      _showHome = true;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (_showHome && _favoriteCity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<WeatherProvider>().fetchWeather(_favoriteCity!);
      });
    }
  }

  Future<void> _completeWithCity(String city) async {
    debugPrint('🏠 [_completeWithCity] START for: $city');
    await AppStorage.setFavoriteCity(city);
    await AppStorage.setHasOnboarded(true);
    debugPrint('🏠 [_completeWithCity] Storage saved');
    if (!mounted) {
      debugPrint('🏠 [_completeWithCity] Not mounted');
      return;
    }
    debugPrint('🏠 [_completeWithCity] Calling setState to show HomeScreen');
    setState(() {
      _favoriteCity = city;
      _showHome = true;
    });
    debugPrint('🏠 [_completeWithCity] DONE');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showHome) {
      return const HomeScreen();
    }

    return OnboardingScreen(
      onCompleteWithCity: _completeWithCity,
    );
  }
}

