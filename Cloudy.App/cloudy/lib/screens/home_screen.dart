import 'dart:ui';

import 'package:cloudy/core/storage/app_storage.dart';
import 'package:flutter/material.dart';
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

  String _assetForCondition(String? main) {
    final v = (main ?? '').toLowerCase().trim();
    if (v.contains('thunder')) return 'assets/thunder.json';
    if (v.contains('snow')) return 'assets/snow.json';
    if (v.contains('rain') || v.contains('drizzle')) return 'assets/rain.json';
    if (v.contains('mist') || v.contains('fog') || v.contains('haze') || v.contains('smoke')) return 'assets/mist.json';
    if (v.contains('cloud')) return 'assets/cloudy_day.json';
    return 'assets/clear_day.json';
  }

  Future<void> _changeCity() async {
    final controller = TextEditingController();
    final city = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change city', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Enter a city name',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) =>
              Navigator.of(context).pop(controller.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child:
                Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Search'),
          ),
        ],
      ),
    );

    final value = (city ?? '').trim();
    if (value.isEmpty || !mounted) return;

    await AppStorage.setFavoriteCity(value);
    if (!mounted) return;
    await context.read<WeatherProvider>().fetchWeather(value);
  }

  @override
  Widget build(BuildContext context) {
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
                final state = weatherProvider.state;

                if (state.status == WeatherStatus.loading) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
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
                final chancePct =
                    chance == null ? '--' : '${(chance * 100).round()}%';

                final name = weather.name?.trim() ?? '';

                return Column(
                  children: [
                    // ── Top bar ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Search button — far left
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _glassIconButton(
                              icon: Icons.search,
                              onTap: _changeCity,
                            ),
                          ),

                          // ── City glass pill — centred ──────────────
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_rounded,
                                        color: Colors.white, size: 16),
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

                          // Removed: Calendar button navigation (available in Today panel)
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _statItem(
                                  icon: Icons.air_rounded,
                                  label: 'Wind',
                                  value:
                                      '${weather.wind?.speed?.toStringAsFixed(0) ?? '--'} km/h',
                                ),
                                _divider(),
                                _statItem(
                                  icon: Icons.water_drop_outlined,
                                  label: 'Humidity',
                                  value:
                                      '${weather.main?.humidity ?? '--'}%',
                                ),
                                _divider(),
                                _statItem(
                                  icon: Icons.umbrella_outlined,
                                  label: 'Chance of rain',
                                  value: chancePct,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Dark bottom panel ────────────────────────────
                    if (hourly?.list != null)
                      _bottomPanel(hourly!, context),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom "Today" dark sheet ──────────────────────────────────────
  Widget _bottomPanel(dynamic hourly, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF080E24).withValues(alpha: 0.85),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          padding:
              const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                          builder: (_) => const SevenDaysScreen()),
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
                        Icon(Icons.chevron_right,
                            color: Colors.white.withValues(alpha: 0.70),
                            size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      (hourly.list!.length > 8) ? 8 : hourly.list!.length,
                  itemBuilder: (context, index) {
                    final item = hourly.list![index];
                    final time = DateTime.fromMillisecondsSinceEpoch(
                        (item.dt ?? 0) * 1000);
                    final main = item.weather?.first.main;
                    final iconAsset = _assetForCondition(main);
                    final temp =
                        '${item.main?.temp?.toStringAsFixed(0) ?? '--'}°';
                    final hour =
                        '${time.hour.toString().padLeft(2, '0')}:00';

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
      height: 36,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _errorView(String error, WeatherProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: Colors.white.withValues(alpha: 0.5), size: 64),
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
                    borderRadius: BorderRadius.circular(12)),
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
            Icon(Icons.cloud_outlined,
                color: Colors.white.withValues(alpha: 0.5), size: 64),
            const SizedBox(height: 16),
            Text(
              'Pick a city to see the forecast.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
