import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../game_manager.dart';
import '../models/brick.dart';
import '../models/power_up.dart';
import '../models/coin.dart';
import '../models/hazard.dart';

class GamePainter extends CustomPainter {
  final GameManager manager;

  GamePainter({required this.manager}) : super(repaint: manager);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Apply Screen Shake
    if (manager.shakeOffset != Offset.zero) {
      canvas.save();
      canvas.translate(manager.shakeOffset.dx, manager.shakeOffset.dy);
    }

    // 2. Draw Background
    _drawBackground(canvas, size);

    // 2b. Draw EMP Storm Warning Overlay
    _drawEMPStormOverlay(canvas, size);

    // 2c. Draw Black Hole Vortex
    _drawBlackHole(canvas);

    // 3. Draw Bricks
    _drawBricks(canvas);

    // 4. Draw Power-ups
    _drawPowerUps(canvas);

    // 5. Draw Coins
    _drawCoins(canvas);

    // 5b. Draw Hazards (Bombs & Glitch Orbs)
    _drawHazards(canvas);

    // 5c. Draw Drone Enemies
    _drawDrones(canvas);

    // 5d. Draw Laser Bullets
    _drawLasers(canvas);

    // 6. Draw Paddle
    _drawPaddle(canvas, size.height);

    // 7. Draw Balls
    _drawBalls(canvas);

    // 8. Draw Particles
    _drawParticles(canvas);

    // 9. Draw Floating Texts
    _drawFloatingTexts(canvas);

    // Restore screen shake translation
    if (manager.shakeOffset != Offset.zero) {
      canvas.restore();
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F0E17), Color(0xFF1F1D2C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw a subtle neon grid overlay
    final Paint gridPaint = Paint()
      ..color = const Color(0x0A00FFFF)
      ..strokeWidth = 1.0;
    
    double gridSpacing = 40.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawBricks(Canvas canvas) {
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.fill;
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Paint extraPaint = Paint();

    for (var brick in manager.bricks) {
      if (brick.isDestroyed) continue;

      RRect rrect = RRect.fromRectAndRadius(brick.rect, const Radius.circular(4.0));

      // 1. Draw Neon Glow
      glowPaint.color = brick.glowColor;
      glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawRRect(rrect, glowPaint);

      // 2. Draw Solid Brick Fill
      fillPaint.color = Color.alphaBlend(brick.color.withOpacity(0.15), const Color(0xFF141320));
      canvas.drawRRect(rrect, fillPaint);

      // 3. Draw Neon Border
      borderPaint.color = brick.color;
      canvas.drawRRect(rrect, borderPaint);

      // 4. Custom decals
      if (brick.type == BrickType.explosive) {
        extraPaint.color = brick.color.withOpacity(0.8);
        extraPaint.style = PaintingStyle.stroke;
        extraPaint.strokeWidth = 1.5;
        canvas.drawLine(brick.rect.topLeft + const Offset(4, 4), brick.rect.bottomRight - const Offset(4, 4), extraPaint);
        canvas.drawLine(brick.rect.topRight + const Offset(-4, 4), brick.rect.bottomLeft - const Offset(-4, 4), extraPaint);
      } else if (brick.type == BrickType.armored && brick.health > 1) {
        extraPaint.color = brick.color.withOpacity(0.5);
        extraPaint.style = PaintingStyle.stroke;
        extraPaint.strokeWidth = 1.0;
        canvas.drawRRect(RRect.fromRectAndRadius(brick.rect.deflate(4.0), const Radius.circular(2.0)), extraPaint);
      } else if (brick.type == BrickType.unbreakable) {
        extraPaint.color = brick.color.withOpacity(0.6);
        extraPaint.style = PaintingStyle.fill;
        canvas.drawCircle(brick.rect.topLeft + const Offset(5, 5), 1.8, extraPaint);
        canvas.drawCircle(brick.rect.topRight + const Offset(-5, 5), 1.8, extraPaint);
        canvas.drawCircle(brick.rect.bottomLeft + const Offset(5, -5), 1.8, extraPaint);
        canvas.drawCircle(brick.rect.bottomRight + const Offset(-5, -5), 1.8, extraPaint);

        extraPaint.color = brick.color.withOpacity(0.4);
        extraPaint.style = PaintingStyle.stroke;
        extraPaint.strokeWidth = 1.0;
        canvas.drawLine(brick.rect.centerLeft + const Offset(10, 0), brick.rect.centerRight - const Offset(10, 0), extraPaint);
      }
    }
  }

  void _drawPaddle(Canvas canvas, double screenHeight) {
    Rect paddleRect = manager.paddle.getRect(screenHeight);
    RRect rrect = RRect.fromRectAndRadius(paddleRect, const Radius.circular(8.0));

    Color paddleColor = manager.laserPaddleTimer > 0 ? Colors.amberAccent : manager.paddle.color;
    Color glowColor = manager.laserPaddleTimer > 0 ? Colors.amber.withOpacity(0.6) : manager.paddle.glowColor;

    // 1. Draw Neon Glow
    final Paint glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawRRect(rrect, glowPaint);

    // 2. Draw Solid Fill
    final Paint fillPaint = Paint()
      ..color = paddleColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Draw nozzles if laser active
    if (manager.laserPaddleTimer > 0) {
      final Paint nozzlePaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(paddleRect.left - 4, paddleRect.top + 2, 4, paddleRect.height - 4), nozzlePaint);
      canvas.drawRect(Rect.fromLTWH(paddleRect.right, paddleRect.top + 2, 4, paddleRect.height - 4), nozzlePaint);
    }

    // 3. Draw Highlight
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(paddleRect.left + 8, paddleRect.top + 2, paddleRect.width - 16, 3),
        const Radius.circular(1.0),
      ),
      highlightPaint,
    );

    // 4. Stun Electrocution lines (Yellow static noise)
    if (manager.paddleStunTimer > 0) {
      final Paint stunPaint = Paint()
        ..color = Colors.yellowAccent
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final rand = math.Random();
      for (int k = 0; k < 6; k++) {
        double px1 = paddleRect.left + rand.nextDouble() * paddleRect.width;
        double py1 = paddleRect.top - 6.0 + rand.nextDouble() * (paddleRect.height + 12.0);
        double px2 = px1 + (rand.nextDouble() * 12.0 - 6.0);
        double py2 = py1 + (rand.nextDouble() * 12.0 - 6.0);
        canvas.drawLine(Offset(px1, py1), Offset(px2, py2), stunPaint);
      }
    }
  }

  void _drawBalls(Canvas canvas) {
    for (var ball in manager.balls) {
      Color ballColor = manager.glitchTimer > 0 ? Colors.purpleAccent : ball.color;
      Color ballGlow = manager.glitchTimer > 0 ? Colors.purple.withOpacity(0.6) : ball.glowColor;

      // 1. Draw Ball Glow
      final Paint glowPaint = Paint()
        ..color = ballGlow
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      
      // If glitched, make the radius pulse dynamically
      double radiusOffset = manager.glitchTimer > 0 ? (math.sin(DateTime.now().millisecondsSinceEpoch * 0.05) * 1.5) : 0.0;
      canvas.drawCircle(ball.position, ball.radius + 2 + radiusOffset, glowPaint);

      // 2. Draw Core
      final Paint corePaint = Paint()
        ..color = ballColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(ball.position, ball.radius, corePaint);

      // 3. Draw glitch horizontal lines across the ball core
      if (manager.glitchTimer > 0) {
        final Paint glitchLinePaint = Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(ball.position - Offset(ball.radius, -2), ball.position + Offset(ball.radius, 2), glitchLinePaint);
      }
    }
  }

  void _drawPowerUps(Canvas canvas) {
    for (PowerUp powerUp in manager.powerUps) {
      Rect rect = powerUp.getRect();
      RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(powerUp.radius));

      // 1. Draw Glow
      final Paint glowPaint = Paint()
        ..color = powerUp.glowColor
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawRRect(rrect, glowPaint);

      // 2. Draw Capsule Fill
      final Paint fillPaint = Paint()
        ..color = const Color(0xFF141320)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      // 3. Draw Border
      final Paint borderPaint = Paint()
        ..color = powerUp.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRRect(rrect, borderPaint);

      // 4. Draw Symbol
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: powerUp.label,
          style: TextStyle(
            color: powerUp.color,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        powerUp.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawCoins(Canvas canvas) {
    for (Coin coin in manager.fallingCoins) {
      canvas.save();
      canvas.translate(coin.position.dx, coin.position.dy);
      canvas.rotate(coin.rotationAngle);

      // 1. Draw Glow
      final Paint glowPaint = Paint()
        ..color = coin.glowColor
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(Offset.zero, coin.radius, glowPaint);

      // 2. Draw Golden Border
      final Paint borderPaint = Paint()
        ..color = coin.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(Offset.zero, coin.radius, borderPaint);

      // 3. Draw Golden Inner Star/Diamond shape
      final Paint starPaint = Paint()
        ..color = coin.color
        ..style = PaintingStyle.fill;
      
      Path starPath = Path()
        ..moveTo(0, -coin.radius + 3)
        ..lineTo(coin.radius - 3, 0)
        ..lineTo(0, coin.radius - 3)
        ..lineTo(-coin.radius + 3, 0)
        ..close();
      canvas.drawPath(starPath, starPaint);

      canvas.restore();
    }
  }

  void _drawParticles(Canvas canvas) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (var particle in manager.particleSystem.particles) {
      paint.color = particle.color.withOpacity(particle.life);
      canvas.drawCircle(
        particle.position, 
        particle.size * (particle.life > 0.0 ? particle.life : 0.001), 
        paint
      );
    }
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (var text in manager.floatingTexts) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text.text,
          style: TextStyle(
            color: text.color.withOpacity(text.life > 1.0 ? 1.0 : text.life),
            fontSize: 14.0 + (1.0 - (text.life > 1.0 ? 1.0 : text.life)) * 4.0,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: text.color.withOpacity((text.life > 1.0 ? 1.0 : text.life) * 0.5),
                blurRadius: 8.0,
              ),
            ],
            fontFamily: 'Outfit',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        text.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawHazards(Canvas canvas) {
    for (Hazard hazard in manager.fallingHazards) {
      canvas.save();
      canvas.translate(hazard.position.dx, hazard.position.dy);
      canvas.rotate(hazard.rotationAngle);

      if (hazard.type == HazardType.bomb) {
        // Draw red spiked bomb
        // 1. Glow
        final Paint glowPaint = Paint()
          ..color = hazard.glowColor
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        canvas.drawCircle(Offset.zero, hazard.radius, glowPaint);

        // 2. Draw 6 Spikes (lines radiating outwards)
        final Paint spikePaint = Paint()
          ..color = hazard.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        for (int j = 0; j < 6; j++) {
          double angle = j * (math.pi / 3);
          canvas.drawLine(
            Offset(math.cos(angle) * 6, math.sin(angle) * 6),
            Offset(math.cos(angle) * (hazard.radius + 4), math.sin(angle) * (hazard.radius + 4)),
            spikePaint,
          );
        }

        // 3. Central Core
        final Paint corePaint = Paint()
          ..color = const Color(0xFF1F0D15) // dark red-brown core
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, hazard.radius - 2, corePaint);

        final Paint borderPaint = Paint()
          ..color = hazard.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset.zero, hazard.radius - 2, borderPaint);

        // 4. White central fuse or sparks
        final Paint sparkPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, 2.5, sparkPaint);
      } else {
        // Draw purple neon glitch cross
        // 1. Glow
        final Paint glowPaint = Paint()
          ..color = hazard.glowColor
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: hazard.radius * 2, height: hazard.radius * 2), glowPaint);

        // 2. Outer cross lines
        final Paint crossPaint = Paint()
          ..color = hazard.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        // Horizontal bar
        canvas.drawLine(Offset(-hazard.radius, 0), Offset(hazard.radius, 0), crossPaint);
        // Vertical bar
        canvas.drawLine(Offset(0, -hazard.radius), Offset(0, hazard.radius), crossPaint);

        // 3. Central white glitch square
        final Paint corePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 5.0, height: 5.0), corePaint);
      }

      canvas.restore();
    }
  }

  void _drawDrones(Canvas canvas) {
    for (var drone in manager.drones) {
      if (drone.isDestroyed) continue;
      
      final Offset pos = drone.position;
      final Rect rect = drone.rect;
      
      final Paint glowPaint = Paint()
        ..color = Colors.pink.withOpacity(0.6)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawOval(rect, glowPaint);
      
      final Paint bodyPaint = Paint()
        ..color = const Color(0xFF2C1A24)
        ..style = PaintingStyle.fill;
      canvas.drawOval(rect, bodyPaint);
      
      final Paint borderPaint = Paint()
        ..color = Colors.pinkAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawOval(rect, borderPaint);
      
      canvas.drawLine(Offset(rect.left, pos.dy), Offset(rect.left - 6.0, pos.dy - 3), borderPaint);
      canvas.drawLine(Offset(rect.right, pos.dy), Offset(rect.right + 6.0, pos.dy - 3), borderPaint);
      
      double eyeRadius = 4.0 + math.sin(DateTime.now().millisecondsSinceEpoch * 0.01).abs() * 2.0;
      final Paint eyeGlow = Paint()
        ..color = Colors.red.withOpacity(0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(pos, eyeRadius, eyeGlow);
      
      final Paint eyeCore = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 2.0, eyeCore);
    }
  }

  void _drawLasers(Canvas canvas) {
    for (var bullet in manager.laserBullets) {
      if (bullet.isDestroyed) continue;
      
      final Paint glowPaint = Paint()
        ..color = Colors.amber.withOpacity(0.7)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawRect(bullet.rect, glowPaint);
      
      final Paint corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(bullet.rect.deflate(0.5), corePaint);
    }
    
    for (var bullet in manager.enemyLasers) {
      if (bullet.isDestroyed) continue;
      
      final Paint glowPaint = Paint()
        ..color = Colors.red.withOpacity(0.7)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawRect(bullet.rect, glowPaint);
      
      final Paint corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(bullet.rect.deflate(0.5), corePaint);
    }
  }

  void _drawEMPStormOverlay(Canvas canvas, Size size) {
    if (manager.empStormTimer <= 0) return;

    final rand = math.Random();
    
    if (rand.nextDouble() < 0.8) {
      final Paint borderPaint = Paint()
        ..color = Colors.redAccent.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
    }

    final Paint linePaint = Paint()
      ..color = Colors.red.withOpacity(0.08)
      ..strokeWidth = 2.0;
    for (int k = 0; k < 3; k++) {
      double y = rand.nextDouble() * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  void _drawBlackHole(Canvas canvas) {
    if (manager.blackHolePosition == null) return;

    final Offset pos = manager.blackHolePosition!;
    final double radius = 30.0;
    final int timeMs = DateTime.now().millisecondsSinceEpoch;

    final Paint glowPaint = Paint()
      ..color = Colors.purple.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0);
    
    double pulse = math.sin(timeMs * 0.005).abs() * 6.0;
    canvas.drawCircle(pos, radius + pulse, glowPaint);

    final Paint spiralPaint = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(timeMs * 0.002);

    for (int j = 0; j < 3; j++) {
      double angleOffset = j * (2 * math.pi / 3);
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        angleOffset,
        math.pi / 2,
        false,
        spiralPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius * 0.6),
        angleOffset + math.pi / 3,
        math.pi / 2,
        false,
        spiralPaint,
      );
    }
    canvas.restore();

    final Paint corePaint = Paint()
      ..color = const Color(0xFF0F0E17)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 10.0, corePaint);

    final Paint coreBorder = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(pos, 10.0, coreBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
