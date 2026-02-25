import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color tintColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(16),
    this.tintColor = const Color(0x1AFFFFFF),
  });

  bool get _useFallback {
    if (kIsWeb) return true;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return false;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    if (_useFallback) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tintColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: content,
          ),
        ),
      );
    }

    return LiquidGlass.withOwnLayer(
      settings: LiquidGlassSettings(
        blur: 10,
        thickness: 10,
        glassColor: tintColor,
        lightIntensity: 1.2,
        ambientStrength: 0.08,
        saturation: 1.0,
      ),
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      child: content,
    );
  }
}

