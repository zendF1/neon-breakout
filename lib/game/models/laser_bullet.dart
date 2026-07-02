import 'package:flutter/material.dart';

class LaserBullet {
  Offset position;
  final Offset velocity;
  final bool isEnemy;
  final double width;
  final double height;
  bool isDestroyed;

  LaserBullet({
    required this.position,
    required this.velocity,
    required this.isEnemy,
    this.width = 3.0,
    this.height = 16.0,
    this.isDestroyed = false,
  });

  void update(double deltaTime) {
    position += velocity * deltaTime;
  }

  Rect get rect => Rect.fromLTWH(
        position.dx - width / 2,
        position.dy - height / 2,
        width,
        height,
      );
}