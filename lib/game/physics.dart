import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models/ball.dart';
import 'models/paddle.dart';
import 'models/brick.dart';
import 'models/laser_bullet.dart';
import 'models/drone_enemy.dart';

class CollisionInfo {
  final bool collided;
  final Offset? normal; // Normal vector of the collision surface
  final double? hitFactor; // Only for paddle hits: -1.0 to 1.0

  CollisionInfo({required this.collided, this.normal, this.hitFactor});
}

class PhysicsEngine {
  /// Checks and resolves collision between Ball and Screen Boundaries.
  /// Returns 'lost' if the ball fell below the bottom edge.
  static String? checkBoundaryCollision(Ball ball, double width, double height) {
    // Left boundary
    if (ball.position.dx - ball.radius < 0) {
      ball.position = Offset(ball.radius, ball.position.dy);
      ball.bounceX();
      return 'left';
    }
    // Right boundary
    if (ball.position.dx + ball.radius > width) {
      ball.position = Offset(width - ball.radius, ball.position.dy);
      ball.bounceX();
      return 'right';
    }
    // Top boundary
    if (ball.position.dy - ball.radius < 0) {
      ball.position = Offset(ball.position.dx, ball.radius);
      ball.bounceY();
      return 'top';
    }
    // Bottom boundary (out of bounds)
    if (ball.position.dy - ball.radius > height) {
      return 'lost';
    }
    return null;
  }

  /// Checks and resolves collision between Ball and Paddle.
  static bool checkPaddleCollision(Ball ball, Paddle paddle, double screenHeight) {
    Rect paddleRect = paddle.getRect(screenHeight);
    
    // Find closest point on paddle to ball
    double closestX = ball.position.dx.clamp(paddleRect.left, paddleRect.right);
    double closestY = ball.position.dy.clamp(paddleRect.top, paddleRect.bottom);
    
    double distanceX = ball.position.dx - closestX;
    double distanceY = ball.position.dy - closestY;
    double distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);
    
    if (distanceSquared < ball.radius * ball.radius) {
      // Only bounce if the ball is moving downwards to prevent catching inside paddle
      if (ball.velocity.dy > 0) {
        // Calculate hit factor based on where the ball hit the paddle (-1.0 to 1.0)
        double relativeHitX = closestX - paddleRect.center.dx;
        double hitFactor = relativeHitX / (paddleRect.width / 2);
        // Clamp hitFactor to [-1.0, 1.0]
        hitFactor = hitFactor.clamp(-1.0, 1.0);
        
        // Relocate ball slightly above the paddle to prevent sticking
        ball.position = Offset(ball.position.dx, paddleRect.top - ball.radius);
        
        // Bounce the ball reflecting the hit angle
        ball.bounceOffPaddle(hitFactor);
        return true;
      }
    }
    return false;
  }

  /// Checks and resolves collision between Ball and Brick.
  /// If collided, it updates the ball velocity and returns true.
  static bool checkBrickCollision(Ball ball, Brick brick) {
    if (brick.isDestroyed) return false;
    
    Rect brickRect = brick.rect;
    
    // Find the closest point on the brick to the ball center
    double closestX = ball.position.dx.clamp(brickRect.left, brickRect.right);
    double closestY = ball.position.dy.clamp(brickRect.top, brickRect.bottom);
    
    double distanceX = ball.position.dx - closestX;
    double distanceY = ball.position.dy - closestY;
    
    double distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);
    
    if (distanceSquared < ball.radius * ball.radius) {
      // Collision detected!
      
      bool isLeft = closestX == brickRect.left;
      bool isRight = closestX == brickRect.right;
      bool isTop = closestY == brickRect.top;
      bool isBottom = closestY == brickRect.bottom;
      
      // 1. Resolve collision based on which face closest point lies, and direction of ball velocity
      if (isLeft && ball.position.dx < brickRect.left && ball.velocity.dx > 0) {
        ball.position = Offset(brickRect.left - ball.radius, ball.position.dy);
        ball.bounceX();
        return true;
      }
      if (isRight && ball.position.dx > brickRect.right && ball.velocity.dx < 0) {
        ball.position = Offset(brickRect.right + ball.radius, ball.position.dy);
        ball.bounceX();
        return true;
      }
      if (isTop && ball.position.dy < brickRect.top && ball.velocity.dy > 0) {
        ball.position = Offset(ball.position.dx, brickRect.top - ball.radius);
        ball.bounceY();
        return true;
      }
      if (isBottom && ball.position.dy > brickRect.bottom && ball.velocity.dy < 0) {
        ball.position = Offset(ball.position.dx, brickRect.bottom + ball.radius);
        ball.bounceY();
        return true;
      }
      
      // 2. Fallback: if the ball is inside the brick center (distanceX == 0 and distanceY == 0)
      // or edge-cases where ball did not satisfy directional check (already overlapping).
      // Resolve by comparing the absolute distances to the closest edges.
      double distToLeft = (ball.position.dx - brickRect.left).abs();
      double distToRight = (ball.position.dx - brickRect.right).abs();
      double distToTop = (ball.position.dy - brickRect.top).abs();
      double distToBottom = (ball.position.dy - brickRect.bottom).abs();
      
      double minDist = [distToLeft, distToRight, distToTop, distToBottom].reduce(math.min);
      
      if (minDist == distToLeft && ball.velocity.dx > 0) {
        ball.position = Offset(brickRect.left - ball.radius, ball.position.dy);
        ball.bounceX();
      } else if (minDist == distToRight && ball.velocity.dx < 0) {
        ball.position = Offset(brickRect.right + ball.radius, ball.position.dy);
        ball.bounceX();
      } else if (minDist == distToTop && ball.velocity.dy > 0) {
        ball.position = Offset(ball.position.dx, brickRect.top - ball.radius);
        ball.bounceY();
      } else if (minDist == distToBottom && ball.velocity.dy < 0) {
        ball.position = Offset(ball.position.dx, brickRect.bottom + ball.radius);
        ball.bounceY();
      } else {
        // Absolute fallback: push out along the major velocity axis
        if (ball.velocity.dy.abs() > ball.velocity.dx.abs()) {
          ball.position = Offset(
            ball.position.dx, 
            ball.velocity.dy > 0 ? brickRect.top - ball.radius : brickRect.bottom + ball.radius
          );
          ball.bounceY();
        } else {
          ball.position = Offset(
            ball.velocity.dx > 0 ? brickRect.left - ball.radius : brickRect.right + ball.radius, 
            ball.position.dy
          );
          ball.bounceX();
        }
      }
      return true;
    }
    return false;
  }

  static bool checkBallDroneCollision(Ball ball, DroneEnemy drone) {
    if (drone.isDestroyed) return false;
    
    Rect droneRect = drone.rect;
    
    double closestX = ball.position.dx.clamp(droneRect.left, droneRect.right);
    double closestY = ball.position.dy.clamp(droneRect.top, droneRect.bottom);
    
    double distanceX = ball.position.dx - closestX;
    double distanceY = ball.position.dy - closestY;
    
    double distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);
    
    if (distanceSquared < ball.radius * ball.radius) {
      if (distanceX.abs() > distanceY.abs()) {
        ball.bounceX();
        double overlapX = ball.radius - distanceX.abs();
        double displacementX = (ball.velocity.dx > 0) ? -overlapX : overlapX;
        ball.position = Offset(ball.position.dx + displacementX, ball.position.dy);
      } else {
        ball.bounceY();
        double overlapY = ball.radius - distanceY.abs();
        double displacementY = (ball.velocity.dy > 0) ? -overlapY : overlapY;
        ball.position = Offset(ball.position.dx, ball.position.dy + displacementY);
      }
      return true;
    }
    return false;
  }

  static bool checkLaserBrickCollision(LaserBullet bullet, Brick brick) {
    if (brick.isDestroyed) return false;
    return bullet.rect.overlaps(brick.rect);
  }

  static bool checkLaserPaddleCollision(LaserBullet bullet, Paddle paddle, double screenHeight) {
    return bullet.rect.overlaps(paddle.getRect(screenHeight));
  }
}
