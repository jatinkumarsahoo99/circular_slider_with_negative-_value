part of circular_slider;

class _CurvePainter extends CustomPainter {
  final double angle;
  final CircularSliderAppearance appearance;
  final double startAngle;
  final double angleRange;

  Offset? handler;
  Offset? center;
  late double radius;

  _CurvePainter({required this.appearance, this.angle = 30, required this.startAngle, required this.angleRange});

  @override
  void paint(Canvas canvas, Size size) {
    radius = math.min(size.width / 2, size.height / 2) - appearance.progressBarWidth * 0.5;
    center = Offset(size.width / 2, size.height / 2);

    final progressBarRect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);

    Paint trackPaint;
    if (appearance.trackColors != null) {
      final trackGradient = SweepGradient(
        startAngle: degreeToRadians(appearance.trackGradientStartAngle),
        endAngle: degreeToRadians(appearance.trackGradientStopAngle),
        tileMode: TileMode.mirror,
        colors: appearance.trackColors!,
      );
      trackPaint = Paint()
        ..shader = trackGradient.createShader(progressBarRect)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth;
    } else {
      trackPaint = Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = appearance.trackWidth
        ..color = appearance.trackColor;
    }
    drawCircularArc(canvas: canvas, size: size, paint: trackPaint, ignoreAngle: true, spinnerMode: appearance.spinnerMode);

    if (!appearance.hideShadow) {
      drawShadow(canvas: canvas, size: size);
    }

    final currentAngle = appearance.counterClockwise ? -angle : angle;
    final dynamicGradient = appearance.dynamicGradient;
    final gradientRotationAngle = dynamicGradient
        ? appearance.counterClockwise
            ? startAngle + 10.0
            : startAngle - 10.0
        : 0.0;
    final GradientRotation rotation = GradientRotation(degreeToRadians(gradientRotationAngle));

    final gradientStartAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0 - currentAngle.abs()
            : 0.0
        : appearance.gradientStartAngle;
    final gradientEndAngle = dynamicGradient
        ? appearance.counterClockwise
            ? 360.0
            : currentAngle.abs()
        : appearance.gradientStopAngle;
    final colors = dynamicGradient && appearance.counterClockwise
        ? appearance.progressBarColors.reversed.toList()
        : appearance.progressBarColors;

    final progressBarGradient = kIsWeb
        ? LinearGradient(
            tileMode: TileMode.mirror,
            colors: colors,
          )
        : SweepGradient(
            transform: rotation,
            startAngle: degreeToRadians(gradientStartAngle),
            endAngle: degreeToRadians(gradientEndAngle),
            tileMode: TileMode.mirror,
            colors: colors,
          );

    final progressBarPaint = Paint()
      ..shader = progressBarGradient.createShader(progressBarRect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = appearance.progressBarWidth;
    drawCircularArc(canvas: canvas, size: size, paint: progressBarPaint);

    var dotPaint = Paint()..color =  Colors.grey;

    Offset handler = degreesToCoordinates(center!, -math.pi / 2 + startAngle + currentAngle + 1.5, radius);
    canvas.drawCircle(handler, 5, dotPaint);

   /* // Draw the triangle thumb slider inside the circle
    var thumbPaint = Paint()..color = const Color(0xFF0A6A69);

    // Position the triangle inside the circle
    handler = degreesToCoordinates(
        center!, -math.pi / 2 + startAngle + currentAngle + 1.5, radius - 25); // Slightly inside the circle

    // Calculate the angle for the triangle to remain parallel to the progress
    final double thumbAngle = math.atan2(handler.dy - center!.dy, handler.dx - center!.dx);

    // Draw the triangle inside the circle
    drawTriangle2(canvas, handler, 12, thumbAngle, thumbPaint);*/

    // Draw the minute stick (thumb) inside the circle
    var thumbPaint = Paint()..color = const Color(0xFF0A6A69);

    // Position the minute stick slightly inside the circle
    Offset thumbPosition = degreesToCoordinates(
        center!, -math.pi / 2 + startAngle + currentAngle + 1.5, radius - 25); // Positioned slightly inside

    // Calculate the angle to ensure the minute stick is pointing toward the dot
    final double thumbAngle = math.atan2(handler.dy - center!.dy, handler.dx - center!.dx);

    // Draw the minute stick (thumb)
    drawMinuteStick(canvas, thumbPosition, thumbAngle, thumbPaint);

    // Add fixed lines to track progress in eight directions
    const double lineLength = 20.0; // Length of the tracking lines
    final Paint linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.7) // Customize the color
      ..strokeWidth = 2.0;

    // Cardinal directions
    drawInnerLineAtAngle(canvas, linePaint, 0, lineLength); // Right
    drawInnerLineAtAngle(canvas, linePaint, 90, lineLength); // Top
    drawInnerLineAtAngle(canvas, linePaint, 180, lineLength); // Left
    drawInnerLineAtAngle(canvas, linePaint, 270, lineLength); // Bottom

    // Diagonal directions
    drawInnerLineAtAngle(canvas, linePaint, 45, lineLength); // Top-Right
    drawInnerLineAtAngle(canvas, linePaint, 135, lineLength); // Top-Left
    drawInnerLineAtAngle(canvas, linePaint, 225, lineLength); // Bottom-Left
    drawInnerLineAtAngle(canvas, linePaint, 315, lineLength); // Bottom-Right
  }

  // Draws the minute stick (rectangular line) perpendicular to the dot
  void drawMinuteStick(Canvas canvas, Offset position, double angle, Paint paint) {
    canvas.save();

    // Translate to the minute stick's position
    canvas.translate(position.dx, position.dy);

    // Rotate the canvas to keep the stick perpendicular to the circle's progress point
    canvas.rotate(angle + math.pi / 2);  // Rotate to make it perpendicular

    // Draw a rectangle (thin line) to represent the minute stick
    final Rect rect = Rect.fromCenter(center: const Offset(0, 0), width: 4, height: 0); // Width and height of the stick

    // Draw the minute stick
    canvas.drawRect(rect, paint);

    // Draw the arrowhead at the top of the minute stick
    drawArrowhead(canvas, paint, 25.0); // Arrowhead size

    canvas.restore();
  }

  // Draws an arrowhead on top of the minute stick
  void drawArrowhead(Canvas canvas, Paint paint, double size) {
    final Path arrowPath = Path();
    arrowPath.moveTo(0, size); // Top point (pointing up)
    arrowPath.lineTo(-size / 2, 0); // Bottom left point
    arrowPath.lineTo(size / 2, 0); // Bottom right point
    arrowPath.close(); // Connect back to the starting point

    // Draw the arrowhead
    canvas.drawPath(arrowPath, paint);
  }

  void drawTriangle(Canvas canvas, Offset position, double size, Paint paint) {
    // Calculate the three points of the triangle
    final path = Path();
    path.moveTo(position.dx, position.dy - size); // Top point
    path.lineTo(position.dx - size, position.dy + size); // Bottom left point
    path.lineTo(position.dx + size, position.dy + size); // Bottom right point
    path.close(); // Connect back to the starting point

    // Draw the triangle
    canvas.drawPath(path, paint);
  }

  // Modify the drawTriangle function to accept the angle
  void drawTriangle2(Canvas canvas, Offset position, double size, double angle, Paint paint) {
    // Save the canvas state before applying transformations
    canvas.save();

    // Translate to the triangle's position
    canvas.translate(position.dx, position.dy);

    // Rotate the canvas to point the triangle towards the dot
    canvas.rotate(angle);

    // Calculate the three points of the triangle
    final path = Path();
    path.moveTo(0, -size); // Top point (pointing up)
    path.lineTo(-size, size); // Bottom left point
    path.lineTo(size, size); // Bottom right point
    path.close(); // Connect back to the starting point

    // Draw the triangle
    canvas.drawPath(path, paint);

    // Restore the canvas state to prevent inconsistency
    canvas.restore();
  }

  void drawLineAtAngle(Canvas canvas, Paint paint, double angle, double length) {
    final double radians = degreeToRadians(angle);
    final Offset lineStart = Offset(
      center!.dx + (radius - 5) * math.cos(radians), // Slightly inside
      center!.dy + (radius - 5) * math.sin(radians),
    );
    final Offset lineEnd = Offset(
      center!.dx + (radius - 5 + length) * math.cos(radians), // Extend the line
      center!.dy + (radius - 5 + length) * math.sin(radians),
    );

    canvas.drawLine(lineStart, lineEnd, paint);
  }

  void drawInnerLineAtAngle(Canvas canvas, Paint paint, double angle, double length) {
    final double radians = degreeToRadians(angle);
    final Offset lineStart = Offset(
      center!.dx + (radius - 25) * math.cos(radians), // Start inside the circle
      center!.dy + (radius - 25) * math.sin(radians),
    );
    final Offset lineEnd = Offset(
      center!.dx + (radius - 25 + length) * math.cos(radians), // End point of the line
      center!.dy + (radius - 25 + length) * math.sin(radians),
    );

    canvas.drawLine(lineStart, lineEnd, paint);
  }

  drawCircularArc(
      {required Canvas canvas, required Size size, required Paint paint, bool ignoreAngle = false, bool spinnerMode = false}) {
    final double angleValue = ignoreAngle ? 0 : (angleRange - angle);
    final range = appearance.counterClockwise ? -angleRange : angleRange;
    final currentAngle = appearance.counterClockwise ? angleValue : -angleValue;
    canvas.drawArc(Rect.fromCircle(center: center!, radius: radius), degreeToRadians(spinnerMode ? 0 : startAngle),
        degreeToRadians(spinnerMode ? 360 : range + currentAngle), false, paint);
  }

  drawShadow({required Canvas canvas, required Size size}) {
    final shadowStep = appearance.shadowStep != null
        ? appearance.shadowStep!
        : math.max(1, (appearance.shadowWidth - appearance.progressBarWidth) ~/ 10);
    final maxOpacity = math.min(1.0, appearance.shadowMaxOpacity);
    final repetitions = math.max(1, ((appearance.shadowWidth - appearance.progressBarWidth) ~/ shadowStep));
    final opacityStep = maxOpacity / repetitions;
    final shadowPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= repetitions; i++) {
      shadowPaint.strokeWidth = appearance.progressBarWidth + i * shadowStep;
      shadowPaint.color = appearance.shadowColor.withOpacity(maxOpacity - (opacityStep * (i - 1)));
      drawCircularArc(canvas: canvas, size: size, paint: shadowPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
