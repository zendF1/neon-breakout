import 'package:flutter/material.dart';

class Paddle {
  double positionX; // Center X position of the paddle
  double width;
  double height;
  final double baseWidth;
  final Color color;
  final Color glowColor;

  Paddle({
    required this.positionX,
    this.width = 100.0,
    this.height = 15.0,
    this.color = const Color(0xFFFF007F), // Neon Pink
    this.glowColor = const Color(0x99FF007F),
  }) : baseWidth = width;

  void move(double deltaX, double screenWidth) {
    positionX += deltaX;
    // Keep paddle within screen boundaries
    double halfWidth = width / 2;
    if (positionX - halfWidth < 0) {
      positionX = halfWidth;
    } else if (positionX + halfWidth > screenWidth) {
      positionX = screenWidth - halfWidth;
    }
  }

  void setWidthMultiplier(double multiplier) {
    width = baseWidth * multiplier;
  }

  Rect getRect(double screenHeight) {
    // Paddle is placed slightly above the bottom of the screen (e.g. 50px offset)
    return Rect.fromLTWH(
      positionX - (width / 2),
      screenHeight - 70.0, // 70px from bottom of the canvas
      width,
      height,
    );
  }
}
