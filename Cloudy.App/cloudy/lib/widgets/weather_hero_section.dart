import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherHeroSection extends StatelessWidget {
  final double? temperature;
  final String? condition;
  final String dateText;
  final String animationAsset;

  const WeatherHeroSection({
    super.key,
    required this.temperature,
    required this.condition,
    required this.dateText,
    required this.animationAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        
        // Large floating weather icon
        SizedBox(
          height: 220,
          width: 220,
          child: Lottie.asset(animationAsset, repeat: true),
        ),
        const SizedBox(height: 8),

        // Giant temperature
        Text(
          '${temperature?.toStringAsFixed(0) ?? '--'}°',
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
          condition ?? 'Unknown',
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
      ],
    );
  }
}
