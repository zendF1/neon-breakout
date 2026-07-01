import 'dart:math' as math;
import 'package:flutter/material.dart';

class Ball {
  Offset position;
  Offset velocity;
  double radius;
  double baseSpeed;
  double currentSpeed;
  Color color;
  Color glowColor;

  Ball({
    required this.position,
    required this.velocity,
    this.radius = 8.0,
    this.baseSpeed = 320.0,
    this.color = const Color(0xFFFFFFFF),
    this.glowColor = const Color(0x99FFFFFF),
  })  : currentSpeed = baseSpeed {
    if (velocity.distance > 0) {
      velocity = (velocity / velocity.distance) * currentSpeed;
    }
  }

  void update(double deltaTime) {
    position += velocity * deltaTime;
  }

  void bounceX() {
    velocity = Offset(-velocity.dx, velocity.dy);
  }

  void bounceY() {
    velocity = Offset(velocity.dx, -velocity.dy);
  }

  void setSpeed(double multiplier) {
    currentSpeed = baseSpeed * multiplier;
    if (velocity.distance > 0) {
      velocity = (velocity / velocity.distance) * currentSpeed;
    }
  }

  void bounceOffPaddle(double hitFactor) {
    // hitFactor: -1.0 (left edge) to 1.0 (right edge)
    // Map hitFactor to an angle between -60 and 60 degrees (-pi/3 to pi/3)
    double angle = hitFactor * (math.pi / 3);
    
    // We want the ball to go upwards, so dy must be negative
    double dx = currentSpeed * math.sin(angle);
    double dy = -currentSpeed * math.cos(angle);
    
    velocity = Offset(dx, dy);
  }
}
