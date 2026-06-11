import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

class FolderStructureTypeLines extends CustomPainter {
  final bool isLastModule;
  final bool drawHorizontalLine;

  FolderStructureTypeLines({
    this.isLastModule = false,
    this.drawHorizontalLine = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // STYLE OF VERTICAL LINE
    final Paint verticalLine =
        Paint()
          ..color = AppColor.grey.withValues(alpha: 0.3)
          ..strokeWidth = 1.0;

    // STYLE OF HORIZONTAL LINE
    final Paint horizontalLine =
        Paint()
          ..color = AppColor.grey.withValues(alpha: 0.3)
          ..strokeWidth = 1.0;

    // CALCULATES HORIZONTAL CENTER TO THE CANVAS TO ALIGN VERTICALLY
    final double centerX = size.width / 2;

    // HORIZONTAL LINE AND MID-POINT VERTICAL LINE
    const double horizontalLineY = 24.0;

    // ALWAYS DRAW VERTICAL LINE FROM TOP TO THE BOTTOM (OR IN BETWEEN IF THERE IS A CHILD)
    canvas.drawLine(
      Offset(centerX, 0),
      // FULL HEIGHT
      Offset(centerX, horizontalLineY),
      verticalLine,
    );

    // IF THE CURRENT MODULE IS NOT LAST, IT CONTINUES THE VERTICAL LINE DOWN TO THE BOTTOM OF THE TILE
    if (!isLastModule) {
      canvas.drawLine(
        Offset(centerX, horizontalLineY),
        Offset(centerX, size.height),
        verticalLine,
      );
    }

    // DRAWS HORIZONTAL LINE, IT APPEARS ONLY AT THE TITLE's HEIGHT
    if (drawHorizontalLine) {
      canvas.drawLine(
        // STARTS AT TITLE HEIGHT
        Offset(centerX, horizontalLineY),
        // ENDS AT TITLE WIDTH
        Offset(size.width, horizontalLineY),
        horizontalLine,
      );
    }
  }

  //  TO REPEAT THE PAINT
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
