import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  final Color color;
  double size;
  double life; // Remaining lifetime from 1.0 down to 0.0
  final double decaySpeed;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    this.size = 3.0,
    double lifetimeSeconds = 0.6,
  })  : life = 1.0,
        decaySpeed = 1.0 / lifetimeSeconds;

  void update(double deltaTime) {
    position += velocity * deltaTime;
    // Apply slight gravity/friction
    velocity = velocity * 0.98;
    life -= decaySpeed * deltaTime;
    if (life < 0) life = 0;
  }

  bool get isDead => life <= 0;
}

class ParticleSystem {
  final List<Particle> particles = [];
  final math.Random _random = math.Random();

  void update(double deltaTime) {
    if (particles.length > 120) {
      particles.removeRange(0, particles.length - 120);
    }
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(deltaTime);
      if (particles[i].isDead) {
        particles.removeAt(i);
      }
    }
  }

  void spawnExplosion(Offset position, Color color, {int count = 12}) {
    if (particles.length > 120) return;
    for (int i = 0; i < count; i++) {
      double angle = _random.nextDouble() * 2 * math.pi;
      double speed = 50.0 + _random.nextDouble() * 150.0;
      double size = 2.0 + _random.nextDouble() * 4.0;
      double lifetime = 0.4 + _random.nextDouble() * 0.5;

      particles.add(
        Particle(
          position: position,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: size,
          lifetimeSeconds: lifetime,
        ),
      );
    }
  }

  void spawnBrickDebris(Rect rect, Color color, {int count = 8}) {
    if (particles.length > 120) return;
    for (int i = 0; i < count; i++) {
      double x = rect.left + _random.nextDouble() * rect.width;
      double y = rect.top + _random.nextDouble() * rect.height;
      double angle = _random.nextDouble() * 2 * math.pi;
      double speed = 30.0 + _random.nextDouble() * 100.0;
      double size = 2.0 + _random.nextDouble() * 3.0;
      double lifetime = 0.3 + _random.nextDouble() * 0.4;

      particles.add(
        Particle(
          position: Offset(x, y),
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
          size: size,
          lifetimeSeconds: lifetime,
        ),
      );
    }
  }
}
