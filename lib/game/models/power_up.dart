import 'package:flutter/material.dart';

enum PowerUpType { multiBall, widePaddle, slowMotion }

class PowerUp {
  Offset position;
  final PowerUpType type;
  final double speed = 150.0; // Falling speed (pixels per second)
  final double radius = 12.0;
  bool isCollected = false;
  bool isExpired = false;

  PowerUp({
    required this.position,
    required this.type,
  });

  void update(double deltaTime) {
    position += Offset(0, speed * deltaTime);
  }

  Color get color {
    switch (type) {
      case PowerUpType.multiBall:
        return Colors.greenAccent;
      case PowerUpType.widePaddle:
        return Colors.blueAccent;
      case PowerUpType.slowMotion:
        return Colors.purpleAccent;
    }
  }

  Color get glowColor {
    return color.withOpacity(0.6);
  }

  String get label {
    switch (type) {
      case PowerUpType.multiBall:
        return "3x";
      case PowerUpType.widePaddle:
        return "↔";
      case PowerUpType.slowMotion:
        return "⏰";
    }
  }

  Rect getRect() {
    return Rect.fromCircle(center: position, radius: radius);
  }
}
