import 'package:cloudy/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../models/forecast_data.dart';
import '../providers/weather_provider.dart';
import '../providers/weather_state.dart';

class SevenDaysScreen extends StatelessWidget {
  const SevenDaysScreen({super.key});

  String _assetForCondition(String? main) {
    final v = (main ?? '').toLowerCase().trim();
    if (v.contains('thunder')) return 'assets/thunder.json';
    if (v.contains('snow')) return 'assets/snow.json';
    if (v.contains('rain') || v.contains('drizzle')) return 'assets/rain.json';
    if (v.contains('mist') || v.contains('fog') || v.contains('haze') || v.contains('smoke')) return 'assets/mist.json';
    if (v.contains('cloud')) return 'assets/cloudy_day.json';
    return 'assets/clear_day.json';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('7 days'),
      ),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Consumer<WeatherProvider>(
                builder: (context, provider, _) {
                  final state = provider.state;
                  if (state.status != WeatherStatus.success || state.data == null) {
                    return const Center(child: Text('No data'));
                  }

                  final list = state.forecast?.list;
                  if (list == null || list.isEmpty) {
                    return const Center(
                      child: Text(
                        'No forecast data available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final days = list.take(7).toList();
                  final tomorrow = days.length > 1 ? days[1] : days.first;
                  final tomorrowMain = tomorrow.weather?.first.main;
                  final tomorrowAsset = _assetForCondition(tomorrowMain);

                  final tMax = tomorrow.temp?.max?.toStringAsFixed(0) ?? '--';
                  final tMin = tomorrow.temp?.min?.toStringAsFixed(0) ?? '--';

                  return ListView(
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(18),
                        borderRadius: 30,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 84,
                              width: 84,
                              child: Lottie.asset(tomorrowAsset, repeat: true),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tomorrow',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (tomorrowMain ?? '').toString(),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$tMax° / $tMin°',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      GlassCard(
                        child: Column(
                          children: [
                            for (var i = 0; i < days.length; i++) ...[
                              _dayRow(context, days[i]),
                              if (i != days.length - 1) const Divider(height: 18),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayRow(BuildContext context, DailyForecast day) {
    final date = DateTime.fromMillisecondsSinceEpoch((day.dt ?? 0) * 1000);
    final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
    final main = day.weather?.first.main;
    final asset = _assetForCondition(main);
    final maxT = day.temp?.max?.toStringAsFixed(0) ?? '--';
    final minT = day.temp?.min?.toStringAsFixed(0) ?? '--';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.w600))),
          SizedBox(
            height: 28,
            width: 28,
            child: Lottie.asset(asset, repeat: false, animate: false),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              (main ?? '').toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('$maxT° / $minT°'),
        ],
      ),
    );
  }
}

