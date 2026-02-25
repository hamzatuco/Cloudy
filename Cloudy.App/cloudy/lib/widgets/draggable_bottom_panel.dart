import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DraggableBottomPanel extends StatefulWidget {
  final dynamic hourly;
  final String Function(String? main) assetForCondition;

  const DraggableBottomPanel({
    super.key,
    required this.hourly,
    required this.assetForCondition,
  });

  @override
  State<DraggableBottomPanel> createState() => _DraggableBottomPanelState();
}

class _DraggableBottomPanelState extends State<DraggableBottomPanel> {
  late DraggableScrollableController _dragController;

  @override
  void initState() {
    super.initState();
    _dragController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _dragController,
      initialChildSize: 0.30,
      minChildSize: 0.30,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [
        0.35,
        0.60,
        0.95,
      ], // Tri stanja: minimizovano, srednje, maksimalno
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF080E24).withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Omogući dragging čak i kada je content na vrhu scroll-a
                  return false;
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Drag handle - kao na Instagram ──────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // ── Hourly forecast section ──────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                        child: Row(
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
                          ],
                        ),
                      ),

                      // ── Hourly chips ──────────────────────────────────
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          itemCount: (widget.hourly.list!.length > 8)
                              ? 8
                              : widget.hourly.list!.length,
                          itemBuilder: (context, index) {
                            final item = widget.hourly.list![index];
                            final time = DateTime.fromMillisecondsSinceEpoch(
                              (item.dt ?? 0) * 1000,
                            );
                            final main = item.weather?.first.main;
                            final iconAsset = widget.assetForCondition(main);
                            final temp =
                                '${item.main?.temp?.toStringAsFixed(0) ?? '--'}°';
                            final hour =
                                '${time.hour.toString().padLeft(2, '0')}:00';

                            final isNow = index == 0;

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
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

                      // ── Next 7 Days section (visible when expanded) ───
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: const Text(
                          'Next 7 Days',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // ── 7 Days forecast list ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: Column(
                          children: List.generate(7, (index) {
                            final dayNames = [
                              'Tomorrow',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun',
                              'Mon',
                            ];

                            final condition = [
                              'Clear',
                              'Rain',
                              'Clear',
                              'Clouds',
                              'Clouds',
                              'Clear',
                              'Clear',
                            ][index];

                            final minTemp = (12 + index);
                            final maxTemp = (12 + index + 1);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.08),
                                      Colors.white.withValues(alpha: 0.04),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Leva strana - Dan i opis
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dayNames[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            condition,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.65,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Sredina - Ikona
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Icon(
                                        condition == 'Clear'
                                            ? Icons.sunny
                                            : condition == 'Rain'
                                            ? Icons.cloud_queue_outlined
                                            : Icons.wb_cloudy_outlined,
                                        color: Colors.white.withValues(
                                          alpha: 0.70,
                                        ),
                                        size: 28,
                                      ),
                                    ),

                                    // Desna strana - Temperature
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '$maxTemp°',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '/ $minTemp°',
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.50,
                                                ),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
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
