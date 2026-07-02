import 'package:flutter/material.dart';

enum BrickType { normal, armored, explosive, unbreakable }

class Brick {
  Rect rect;
  final BrickType type;
  final int maxHealth;
  int health;
  bool isDestroyed = false;

  Brick({
    required this.rect,
    required this.type,
    required this.maxHealth,
  }) : health = maxHealth;

  Color get color {
    switch (type) {
      case BrickType.explosive:
        return Colors.amberAccent;
      case BrickType.armored:
        return health > 1 ? Colors.pinkAccent : Colors.cyanAccent;
      case BrickType.normal:
        return Colors.cyanAccent;
      case BrickType.unbreakable:
        return Colors.blueGrey;
    }
  }

  Color get glowColor {
    return color.withOpacity(0.6);
  }

  // Returns true if brick was destroyed by this hit
  bool hit() {
    if (isDestroyed) return false;
    if (type == BrickType.unbreakable) return false; // Indestructible!
    health--;
    if (health <= 0) {
      isDestroyed = true;
      return true;
    }
    return false;
  }
}
