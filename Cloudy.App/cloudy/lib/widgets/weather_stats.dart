import 'package:flutter/material.dart';

class WeatherStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class WeatherStatsRow extends StatelessWidget {
  final String? windSpeed;
  final int? humidity;
  final String rainChance;

  const WeatherStatsRow({
    super.key,
    required this.windSpeed,
    required this.humidity,
    required this.rainChance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: WeatherStatItem(
              icon: Icons.air_rounded,
              label: 'Wind',
              value: '${windSpeed ?? '--'} km/h',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _divider(),
          ),
          Expanded(
            child: WeatherStatItem(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '${humidity ?? '--'}%',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _divider(),
          ),
          Expanded(
            child: WeatherStatItem(
              icon: Icons.umbrella_outlined,
              label: 'Chance of rain',
              value: rainChance,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 48,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15)),
    );
  }
}
