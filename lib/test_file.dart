import 'dart:math';

import 'package:flutter/material.dart';

class CircleWithLinesPainter extends CustomPainter {
  final double lineSpacing; // Spacing between lines
  final double lineThickness; // Thickness of each line
  final Color lineColor; // Color of the lines

  CircleWithLinesPainter({
    this.lineSpacing = 5.0, // Default spacing between lines
    this.lineThickness = 2.0, // Default line thickness
    this.lineColor = Colors.black, // Default line color
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineThickness;

    double radius = size.width / 2;
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Draw multiple lines at lineSpacing intervals
    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      // Check if the line is within the circle
      if ((centerY - y).abs() <= radius) {
        double lineLength = 2 * sqrt(radius * radius - (centerY - y) * (centerY - y));
        double startX = centerX - lineLength / 2;
        double endX = centerX + lineLength / 2;

        // Draw horizontal line
        canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Redraw the painter when necessary
  }
}

Widget _buildPainter({required Size size}) {
  return CustomPaint(
    size: size,
    painter: CircleWithLinesPainter(
      lineSpacing: 5.0, // Adjust line spacing here
      lineThickness: 2.0, // Adjust line thickness here
      lineColor: Colors.black, // Adjust line color here
    ),
    child: Center(
      child: Transform.scale(
        scale: 0.6,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}
