import 'package:flutter/material.dart';

class Coin {
  Offset position;
  final double speed = 140.0; // Falling speed (pixels per second)
  final double radius = 10.0;
  bool isCollected = false;
  double rotationAngle = 0.0; // Rotation for the visual neon effect

  Coin({
    required this.position,
  });

  void update(double deltaTime) {
    position += Offset(0, speed * deltaTime);
    // Rotate 2.5 radians per second
    rotationAngle += 2.5 * deltaTime;
  }

  Color get color => Colors.amberAccent;
  Color get glowColor => Colors.amber.withOpacity(0.5);

  Rect getRect() {
    return Rect.fromCircle(center: position, radius: radius);
  }
}
