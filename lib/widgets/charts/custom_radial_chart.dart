import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';
import 'package:k3h_erp_app/widgets/utils_widgets.dart';

class CommonRadialChart extends StatelessWidget {
  final List<RadialChartItem> items;
  final int? total;

  const CommonRadialChart({super.key, required this.items, this.total});

  int get calculatedTotal => total ?? items.fold(0, (sum, e) => sum + e.value);

  @override
  Widget build(BuildContext context) {
    final totalValue = calculatedTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 120.h,
          width: 120.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(120.w, 120.h),
                painter: RadialPainter(items: items),
              ),

              // Center Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    totalValue.toString(),
                    style: AppTextStyle.ts16SB(color: AppColor.black),
                  ),
                ],
              ),
            ],
          ),
        ),

        verticalSpacing(height: 16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              items.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _legend(
                    e.color,
                    e.value,
                    e.title,
                    onValueTap: e.onValueTap,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _legend(
    Color color,
    int value,
    String text, {
    VoidCallback? onValueTap,
  }) {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        horizontalSpacing(width: 8),
        Text(text, style: AppTextStyle.ts14M(color: color)),
        Spacer(),
        InkWell(
          onTap:
              onValueTap ??
              () {
                // Handle tap event
              },
          child: Text(
            value.toString().padLeft(2, '0'),
            style:
                onValueTap != null
                    ? AppTextStyle.ts14SB(
                      color: value > 0 ? AppColor.primary : AppColor.grey,
                    )
                    : AppTextStyle.ts14SB(color: color),
          ),
        ),
      ],
    );
  }
}

class RadialPainter extends CustomPainter {
  final List<RadialChartItem> items;

  RadialPainter({required this.items});

  final double stroke = 20;
  final double gapDegrees = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final total = items.fold(0, (sum, e) => sum + e.value);

    if (total == 0) return;

    final center = size.center(Offset.zero);
    final radius = size.width / 2.2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    final gapCount = items.length;
    final usable = 360 - (gapDegrees * gapCount);

    double start = -240;

    for (var item in items) {
      if (item.value <= 0) continue;
      final sweep = (item.value / total) * usable;
      if (sweep <= 0) continue;
      final adjustedSweep = sweep - 4;

      paint.color = item.color;

      canvas.drawArc(rect, _deg(start), _deg(adjustedSweep), false, paint);

      start += sweep + gapDegrees;
    }
  }

  double _deg(double d) => d * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RadialChartItem {
  final String title;
  final int value;
  final Color color;
  final VoidCallback? onValueTap;

  RadialChartItem({
    required this.title,
    required this.value,
    required this.color,
    this.onValueTap,
  });
}
