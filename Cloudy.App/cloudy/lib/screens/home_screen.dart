import 'dart:ui';

import 'package:cloudy/core/storage/app_storage.dart';
import 'package:cloudy/screens/city_search_dialog.dart';
import 'package:cloudy/widgets/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'seven_days_screen.dart';
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

  bool _isFavorite = false;
  String _currentCity = '';

  @override
  void initState() {
    super.initState();
  }

  void _toggleFavorite(String cityName) async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      await AppStorage.setFavoriteCity(cityName);
      print('❤️ [HomeScreen] Added $cityName to favorites');
    } else {
      // Clear favorite when toggling off
      await AppStorage.setFavoriteCity('');
      print('🤍 [HomeScreen] Removed $cityName from favorites');
    }
  }

  String _assetForCondition(String? main) {
    final v = (main ?? '').toLowerCase().trim();
    if (v.contains('thunder')) return 'assets/thunder.json';
    if (v.contains('snow')) return 'assets/snow.json';
    if (v.contains('rain') || v.contains('drizzle')) return 'assets/rain.json';
    if (v.contains('mist') ||
        v.contains('fog') ||
        v.contains('haze') ||
        v.contains('smoke'))
      return 'assets/mist.json';
    if (v.contains('cloud')) return 'assets/cloudy_day.json';
    return 'assets/clear_day.json';
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
                  return _errorView(state.error, weatherProvider);
                }

                if (state.status != WeatherStatus.success ||
                    state.data == null) {
                  return _emptyView();
                }

                final weather = state.data!;
                final condition = weather.weather?.isNotEmpty == true
                    ? weather.weather!.first.main
                    : null;
                final asset = _assetForCondition(condition);
                final hourly = state.hourlyForecast;

                final now = DateTime.now();
                final dateText =
                    '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)}';

                final chance = (hourly?.list?.isNotEmpty == true
                    ? hourly!.list!.first.pop
                    : null);
                final chancePct = chance == null
                    ? '--'
                    : '${(chance * 100).round()}%';

                final name = weather.name?.trim() ?? '';

                return Column(
                  children: [
                    // ── Top bar ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ── Hamburger menu button (top left) ────────────────────
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: const SideMenu(),
                            ),
                          ),

                          // ── City glass pill — tappable (center) ──────────────
                          GestureDetector(
                            onTap: _changeCity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        name.isEmpty ? 'Cloudy' : name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ── Heart button (top right) ────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Implement favorite toggle
                                print(
                                  '❤️ [HomeScreen] Favorite button tapped for: $name',
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 16,
                                    sigmaY: 16,
                                  ),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.favorite_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Hero section (icon + temp + date) ───────────
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large floating weather icon
                          SizedBox(
                            height: 220,
                            width: 220,
                            child: Lottie.asset(asset, repeat: true),
                          ),
                          const SizedBox(height: 8),

                          // Giant temperature
                          Text(
                            '${weather.main?.temp?.toStringAsFixed(0) ?? '--'}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 96,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Condition label
                          Text(
                            (condition ?? 'Unknown').toString(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Date
                          Text(
                            dateText,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.60),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Stats row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _statItem(
                                    icon: Icons.air_rounded,
                                    label: 'Wind',
                                    value:
                                        '${weather.wind?.speed?.toStringAsFixed(0) ?? '--'} km/h',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: _divider(),
                                ),
                                Expanded(
                                  child: _statItem(
                                    icon: Icons.water_drop_outlined,
                                    label: 'Humidity',
                                    value: '${weather.main?.humidity ?? '--'}%',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: _divider(),
                                ),
                                Expanded(
                                  child: _statItem(
                                    icon: Icons.umbrella_outlined,
                                    label: 'Chance of rain',
                                    value: chancePct,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Draggable bottom panel (at bottom of screen) ──────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Consumer<WeatherProvider>(
              builder: (context, weatherProvider, _) {
                final hourly = weatherProvider.state.hourlyForecast;
                if (hourly?.list == null) {
                  return const SizedBox.shrink();
                }
                return DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.15,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) =>
                      _bottomPanel(hourly!, context, scrollController),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Draggable bottom sheet with hourly + 7-day forecast ────────────
  Widget _bottomPanel(
    dynamic hourly,
    BuildContext context,
    ScrollController scrollController,
  ) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF080E24).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              // ── Handle bar ──────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // ── Today section ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SevenDaysScreen(),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '7 days',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.70),
                            fontSize: 14,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withValues(alpha: 0.70),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ── Hourly forecast ─────────────────────────────────
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (hourly.list!.length > 8)
                      ? 8
                      : hourly.list!.length,
                  itemBuilder: (context, index) {
                    final item = hourly.list![index];
                    final time = DateTime.fromMillisecondsSinceEpoch(
                      (item.dt ?? 0) * 1000,
                    );
                    final main = item.weather?.first.main;
                    final iconAsset = _assetForCondition(main);
                    final temp =
                        '${item.main?.temp?.toStringAsFixed(0) ?? '--'}°';
                    final hour = '${time.hour.toString().padLeft(2, '0')}:00';
                    final isNow = index == 0;

                    return Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: _hourChip(
                        hour: hour,
                        temp: temp,
                        asset: iconAsset,
                        highlight: isNow,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // ── 7 day forecast section ───────────────────────────
              Text(
                'Next 7 Days',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Placeholder za 7-day forecast (akan se učitati iz provider-a)
              Consumer<WeatherProvider>(
                builder: (context, weatherProvider, _) {
                  final forecast = weatherProvider.state.forecast;

                  if (forecast?.list == null || forecast!.list!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Loading 7-day forecast...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(
                      forecast.list!.length > 7 ? 7 : forecast.list!.length,
                      (index) {
                        final day = forecast.list![index];
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          (day.dt ?? 0) * 1000,
                        );
                        final maxTemp =
                            day.temp?.max?.toStringAsFixed(0) ?? '--';
                        final minTemp =
                            day.temp?.min?.toStringAsFixed(0) ?? '--';
                        final condition =
                            (day.weather?.isNotEmpty == true
                                ? day.weather!.first.main
                                : 'Unknown') ??
                            'Unknown';
                        final asset = _assetForCondition(condition);
                        final dayName = _weekday(date.weekday);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    dayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Lottie.asset(
                                    asset,
                                    repeat: false,
                                    animate: false,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    condition!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$maxTemp°',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$minTemp°',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hourChip({
    required String hour,
    required String temp,
    required String asset,
    bool highlight = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 68,
      decoration: BoxDecoration(
        gradient: highlight
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
              )
            : null,
        color: highlight ? null : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            temp,
            style: TextStyle(
              color: highlight
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.90),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 38,
            width: 38,
            child: Lottie.asset(asset, repeat: false, animate: false),
          ),
          const SizedBox(height: 4),
          Text(
            hour,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.70), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 48,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15)),
    );
  }

  Widget _errorView(String error, WeatherProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: Colors.white.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              error.isEmpty ? "Couldn't load forecast." : error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => provider.retry(),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_outlined,
              color: Colors.white.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Pick a city to see the forecast.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _changeCity,
              child: const Text('Pick a city'),
            ),
          ],
        ),
      ),
    );
  }

  String _weekday(int weekday) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}
