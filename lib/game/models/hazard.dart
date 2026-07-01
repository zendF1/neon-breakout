import 'package:flutter/material.dart';

enum HazardType { bomb, glitch }

class Hazard {
  Offset position;
  final HazardType type;
  final double speed = 130.0; // Falling speed (pixels per second)
  final double radius = 12.0;
  double rotationAngle = 0.0; // Rotation for visual neon effect

  Hazard({
    required this.position,
    required this.type,
  });

  void update(double deltaTime) {
    position += Offset(0, speed * deltaTime);
    // Rotate bombs/glitches continually
    rotationAngle += 2.0 * deltaTime;
  }

  Color get color {
    switch (type) {
      case HazardType.bomb:
        return Colors.redAccent;
      case HazardType.glitch:
        return Colors.purpleAccent;
    }
  }

  Color get glowColor {
    return color.withOpacity(0.5);
  }

  String get label {
    switch (type) {
      case HazardType.bomb:
        return "💣";
      case HazardType.glitch:
        return "⚡";
    }
  }

  Rect getRect() {
    return Rect.fromCircle(center: position, radius: radius);
  }
}
