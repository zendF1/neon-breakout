import 'package:flutter/material.dart';

class DroneEnemy {
  Offset position;
  Offset velocity;
  final double width;
  final double height;
  int health;
  double shootCooldown;
  bool isDestroyed;

  DroneEnemy({
    required this.position,
    this.velocity = const Offset(80.0, 0.0), // Hover speed horizontally
    this.width = 44.0,
    this.height = 20.0,
    this.health = 1,
    this.shootCooldown = 4.5,
    this.isDestroyed = false,
  });

  void update(double deltaTime, double screenWidth) {
    // Horizontal float
    position += velocity * deltaTime;

    // Bounce off left/right screen boundaries
    double halfWidth = width / 2;
    if (position.dx - halfWidth < 8.0) {
      position = Offset(8.0 + halfWidth, position.dy);
      velocity = Offset(-velocity.dx, velocity.dy);
    } else if (position.dx + halfWidth > screenWidth - 8.0) {
      position = Offset(screenWidth - 8.0 - halfWidth, position.dy);
      velocity = Offset(-velocity.dx, velocity.dy);
    }

    // Cooldown check
    if (shootCooldown > 0) {
      shootCooldown -= deltaTime;
    }
  }

  Rect get rect => Rect.fromLTWH(
        position.dx - width / 2,
        position.dy - height / 2,
        width,
        height,
      );
}