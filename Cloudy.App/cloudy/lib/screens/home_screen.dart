import 'dart:ui';

import 'package:cloudy/core/storage/app_storage.dart';
import 'package:cloudy/screens/city_search_dialog.dart';
import 'package:cloudy/widgets/draggable_bottom_panel.dart';
import 'package:cloudy/widgets/side_menu.dart';
import 'package:cloudy/widgets/weather_empty_view.dart';
import 'package:cloudy/widgets/weather_error_view.dart';
import 'package:cloudy/widgets/weather_header.dart';
import 'package:cloudy/widgets/weather_hero_section.dart';
import 'package:cloudy/widgets/weather_stats.dart';
import 'package:cloudy/widgets/weather_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/weather_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sky-blue → deep navy — matches the reference gradient
  static const _bgTop = Color(0xFF38B6FF);
  static const _bgMid = Color(0xFF1565C0);
  static const _bgBottom = Color(0xFF060C22);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _changeCity() async {
    final city = await showDialog<String?>(
      context: context,
      builder: (context) => const CitySearchDialog(),
    );

    final value = (city ?? '').trim();
    if (value.isEmpty || !mounted) return;

    await AppStorage.setFavoriteCity(value);
    if (!mounted) return;
    await context.read<WeatherProvider>().fetchWeather(value);
  }

  Future<void> _onRefresh() async {
    final currentCity = await AppStorage.getFavoriteCity();
    if (currentCity?.isEmpty != false || !mounted) return;

    debugPrint(
      '🔄 [HomeScreen.onRefresh] Refreshing weather for: $currentCity',
    );
    await context.read<WeatherProvider>().fetchWeather(currentCity!);

    if (mounted) {
      debugPrint('✅ [HomeScreen.onRefresh] Refresh complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 [HomeScreen.build] START');
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bgBottom,
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [_bgTop, _bgMid, _bgBottom],
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────
          SafeArea(
            child: Consumer<WeatherProvider>(
              builder: (context, weatherProvider, child) {
                debugPrint('🏠 [HomeScreen.Consumer] Rebuilding');
                final state = weatherProvider.state;
                debugPrint('🏠 [HomeScreen.Consumer] State: ${state.status}');

                if (state.status == WeatherStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (state.status == WeatherStatus.failure) {
                  return WeatherErrorView(
                    error: state.error,
                    onRetry: weatherProvider.retry,
                    onRefresh: _onRefresh,
                  );
                }

                if (state.status != WeatherStatus.success ||
                    state.data == null) {
                  return WeatherEmptyView(
                    onPickCity: _changeCity,
                    onRefresh: _onRefresh,
                  );
                }

                final weather = state.data!;
                final condition = weather.weather?.isNotEmpty == true
                    ? weather.weather!.first.main
                    : null;
                final asset = WeatherUtils.getAssetForCondition(condition);
                final hourly = state.hourlyForecast;

                final now = DateTime.now();
                final dateText = WeatherUtils.formatDate(now);

                final chance = (hourly?.list?.isNotEmpty == true
                    ? hourly!.list!.first.pop
                    : null);
                final chancePct = WeatherUtils.getRainChancePct(chance);

                final name = weather.name?.trim() ?? '';

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: const Color(0xFF2FA6FF),
                  strokeWidth: 3,
                  child: Stack(
                    children: [
                      // ── Glavni sadržaj u Column sa scroll support ──────────────────────
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // ── Top bar sa hamburger menutom i city pill-om ────────────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // ── Hamburger menu button (top left) ────────────────────
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.all(6),
                                      child: SideMenu(),
                                    ),
                                  ),

                                  // ── City pill i favorite button ────────────────────────
                                  WeatherHeader(
                                    cityName: name,
                                    onCityTap: _changeCity,
                                    onFavoriteTap: () {
                                      debugPrint(
                                        '❤️ [HomeScreen] Favorite button tapped for: $name',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // ── Hero section (icon + temp + date + stats) ───────────
                            WeatherHeroSection(
                              temperature: weather.main?.temp,
                              condition: condition,
                              dateText: dateText,
                              animationAsset: asset,
                            ),

                            // ── Stats row ────────────────────────────────────────────
                            WeatherStatsRow(
                              windSpeed:
                                  weather.wind?.speed?.toStringAsFixed(0),
                              humidity: weather.main?.humidity,
                              rainChance: chancePct,
                            ),

                            const SizedBox(height: 12),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),

                      // ── Draggable bottom panel (na vrhu!) ────────────────────────
                      if (hourly?.list != null)
                        DraggableBottomPanel(
                          hourly: hourly!,
                          assetForCondition: WeatherUtils.getAssetForCondition,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
