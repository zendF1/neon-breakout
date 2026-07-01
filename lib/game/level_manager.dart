import 'package:flutter/material.dart';
import 'models/brick.dart';

class LevelManager {
  static const int cols = 10; // Expanded from 8 to 10 for narrower bricks and more open entries
  static const double spacing = 4.0;
  static const double topOffset = 80.0; // Margin from top of screen

  static List<Brick> buildLevel(int level, double screenWidth) {
    List<Brick> bricks = [];
    
    // Calculate responsive brick size
    double sideMargin = 12.0;
    double availableWidth = screenWidth - (sideMargin * 2) - (spacing * (cols - 1));
    double brickWidth = availableWidth / cols;
    double brickHeight = 18.0; // Reduced height for better proportions

    // Define level layouts using custom grid arrays (exactly 10 columns per row)
    // 0: Empty, 1: Normal, 2: Armored, 3: Explosive, 4: Unbreakable
    List<List<int>> layout = [];

    switch (level) {
      // --- TIER 1: BASICS (Levels 1 - 5) ---
      case 1:
        // Standard Grid
        layout = [
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ];
        break;
      case 2:
        // Neon Heart (padded to 10 columns)
        layout = [
          [0, 0, 1, 1, 0, 0, 1, 1, 0, 0],
          [0, 1, 2, 2, 1, 1, 2, 2, 1, 0],
          [1, 2, 1, 2, 2, 2, 2, 1, 2, 1],
          [0, 1, 2, 2, 2, 2, 2, 2, 1, 0],
          [0, 0, 1, 2, 2, 2, 2, 1, 0, 0],
          [0, 0, 0, 1, 2, 2, 1, 0, 0, 0],
          [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
        ];
        break;
      case 3:
        // Neon Pyramid
        layout = [
          [0, 0, 0, 0, 2, 2, 0, 0, 0, 0],
          [0, 0, 0, 2, 1, 1, 2, 0, 0, 0],
          [0, 0, 2, 1, 1, 1, 1, 2, 0, 0],
          [0, 2, 1, 1, 1, 1, 1, 1, 2, 0],
          [2, 1, 1, 1, 1, 1, 1, 1, 1, 2],
        ];
        break;
      case 4:
        // Double Towers
        layout = [
          [2, 1, 0, 0, 0, 0, 0, 0, 1, 2],
          [2, 1, 0, 0, 0, 0, 0, 0, 1, 2],
          [2, 1, 0, 0, 0, 0, 0, 0, 1, 2],
          [2, 2, 0, 0, 0, 0, 0, 0, 2, 2],
          [1, 1, 0, 0, 0, 0, 0, 0, 1, 1],
        ];
        break;
      case 5:
        // Checkerboard
        layout = [
          [1, 2, 1, 2, 1, 2, 1, 2, 1, 2],
          [2, 1, 2, 1, 2, 1, 2, 1, 2, 1],
          [1, 2, 1, 2, 1, 2, 1, 2, 1, 2],
          [2, 1, 2, 1, 2, 1, 2, 1, 2, 1],
        ];
        break;

      // --- TIER 2: SHIELDS (Levels 6 - 10) ---
      case 6:
        // Defensive Wall
        layout = [
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
          [4, 4, 0, 0, 4, 4, 0, 0, 4, 4], // Unbreakable shield row with two 2-block gaps
          [1, 1, 0, 0, 1, 1, 0, 0, 1, 1],
        ];
        break;
      case 7:
        // Space Invader with indestructible shield wings
        layout = [
          [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
          [0, 1, 0, 0, 3, 3, 0, 0, 1, 0],
          [0, 4, 4, 0, 2, 2, 0, 4, 4, 0], // Indestructible shields with outer slots
          [4, 2, 1, 4, 2, 2, 4, 1, 2, 4], // Indestructible borders
          [2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
          [0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
        ];
        break;
      case 8:
        // Spiral Tunnel: Indestructible barrier around breakable bricks
        layout = [
          [4, 4, 4, 4, 0, 0, 4, 4, 4, 4], // 2-block wide gap in top center
          [4, 0, 0, 0, 0, 0, 0, 0, 0, 4],
          [4, 0, 2, 2, 3, 3, 2, 2, 0, 4],
          [4, 0, 1, 1, 0, 0, 1, 1, 0, 4],
          [4, 0, 1, 1, 1, 1, 1, 1, 0, 4],
          [4, 4, 4, 4, 4, 4, 4, 4, 4, 4], // Bottom blocked
        ];
        break;
      case 9:
        // Diamond Defense: Indestructible outer diamond frame
        layout = [
          [0, 0, 0, 0, 3, 3, 0, 0, 0, 0],
          [0, 0, 0, 4, 1, 1, 4, 0, 0, 0], // Indestructible diagonal bounds
          [0, 0, 4, 1, 2, 2, 1, 4, 0, 0],
          [0, 4, 1, 2, 3, 3, 2, 1, 4, 0],
          [3, 1, 2, 3, 0, 0, 3, 2, 1, 3], // Large gaps on side edges for entry bank shots
          [0, 4, 1, 2, 3, 3, 2, 1, 4, 0],
          [0, 0, 4, 1, 2, 2, 1, 4, 0, 0],
          [0, 0, 0, 4, 1, 1, 4, 0, 0, 0],
        ];
        break;
      case 10:
        // Hourglass Funnel
        layout = [
          [2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
          [4, 4, 4, 4, 0, 0, 4, 4, 4, 4], // Funnel wall with 2-block center gap
          [0, 0, 4, 0, 0, 0, 0, 4, 0, 0],
          [0, 0, 0, 0, 3, 3, 0, 0, 0, 0], // Center target
          [0, 0, 4, 0, 0, 0, 0, 4, 0, 0],
          [4, 4, 4, 4, 0, 0, 4, 4, 4, 4],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ];
        break;

      // --- TIER 3: HAZARDS (Levels 11 - 15) ---
      case 11:
        // Bomb Zone
        layout = [
          [3, 1, 3, 1, 1, 1, 1, 3, 1, 3],
          [1, 2, 1, 2, 2, 2, 2, 1, 2, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ];
        break;
      case 12:
        // Warp Columns (Deflectors enabled)
        layout = [
          [2, 0, 2, 0, 0, 0, 0, 2, 0, 2],
          [4, 0, 4, 1, 1, 1, 1, 4, 0, 4], // Warp shields
          [1, 0, 1, 2, 2, 2, 2, 1, 0, 1],
          [1, 0, 1, 1, 1, 1, 1, 1, 0, 1],
        ];
        break;
      case 13:
        // Minefield
        layout = [
          [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
          [3, 2, 2, 3, 3, 3, 3, 2, 2, 3],
          [3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ];
        break;
      case 14:
        // The Maze
        layout = [
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
          [4, 4, 4, 4, 4, 4, 4, 4, 0, 0], // Dividers with 2-block side gaps
          [2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
          [0, 0, 4, 4, 4, 4, 4, 4, 4, 4],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ];
        break;
      case 15:
        // Hourglass Chambers
        layout = [
          [4, 1, 4, 1, 1, 1, 1, 4, 1, 4],
          [1, 4, 1, 4, 4, 4, 4, 1, 4, 1],
          [4, 1, 4, 3, 3, 3, 3, 4, 1, 4],
          [1, 4, 1, 4, 4, 4, 4, 1, 4, 1],
        ];
        break;

      // --- TIER 4: CHAOS (Levels 16 - 20) ---
      case 16:
        // The Cage
        layout = [
          [4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
          [4, 2, 2, 3, 3, 3, 3, 2, 2, 4],
          [4, 2, 1, 1, 1, 1, 1, 1, 2, 4],
          [4, 1, 1, 1, 1, 1, 1, 1, 1, 4],
          [4, 0, 0, 0, 0, 0, 0, 0, 0, 4], // Open bottom corner entry slots (2-block wide)
        ];
        break;
      case 17:
        // Zig-Zag Fortress
        layout = [
          [2, 2, 4, 0, 0, 0, 0, 4, 2, 2],
          [0, 4, 2, 2, 2, 2, 2, 2, 4, 0],
          [4, 2, 2, 3, 3, 3, 3, 2, 2, 4],
          [0, 4, 1, 1, 1, 1, 1, 1, 4, 0],
          [2, 2, 4, 0, 0, 0, 0, 4, 2, 2],
        ];
        break;
      case 18:
        // Crossfire Maze
        layout = [
          [4, 3, 4, 1, 1, 1, 1, 4, 3, 4],
          [3, 4, 3, 4, 4, 4, 4, 3, 4, 3],
          [4, 3, 4, 2, 2, 2, 2, 4, 3, 4],
          [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ];
        break;
      case 19:
        // Iron Fortress
        layout = [
          [4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
          [4, 2, 2, 2, 2, 2, 2, 2, 2, 4],
          [4, 2, 3, 3, 3, 3, 3, 3, 2, 4],
          [4, 2, 2, 2, 2, 2, 2, 2, 2, 4],
          [4, 4, 4, 4, 0, 0, 4, 4, 4, 4], // 2-block entrance at bottom center
        ];
        break;
      case 20:
        // The Grand Finale
        layout = [
          [4, 3, 4, 3, 3, 3, 3, 4, 3, 4],
          [3, 4, 2, 4, 4, 4, 4, 2, 4, 3],
          [4, 2, 2, 2, 2, 2, 2, 2, 2, 4],
          [2, 4, 1, 4, 4, 4, 4, 1, 4, 2],
          [4, 1, 1, 1, 1, 1, 1, 1, 1, 4],
          [1, 1, 3, 1, 1, 1, 1, 3, 1, 1],
        ];
        break;

      default:
        // Infinite Endless Procedural Mode beyond 20
        int rows = 5 + (level % 4);
        layout = List.generate(rows, (r) {
          return List.generate(cols, (c) {
            double rand = (r * 13 + c * 19 + level * 29) % 100 / 100.0;
            if (rand < 0.10) return 4; // Unbreakable
            if (rand < 0.25) return 3; // Explosive
            if (rand < 0.55) return 2; // Armored
            if (rand < 0.90) return 1; // Normal
            return 0; // Empty
          });
        });
    }

    // Build the brick entities based on the layout grid
    for (int row = 0; row < layout.length; row++) {
      for (int col = 0; col < layout[row].length; col++) {
        int cell = layout[row][col];
        if (cell == 0) continue;

        double x = sideMargin + col * (brickWidth + spacing);
        double y = topOffset + row * (brickHeight + spacing);
        Rect rect = Rect.fromLTWH(x, y, brickWidth, brickHeight);

        BrickType type = BrickType.normal;
        int maxHealth = 1;

        if (cell == 2) {
          type = BrickType.armored;
          maxHealth = 2;
        } else if (cell == 3) {
          type = BrickType.explosive;
          maxHealth = 1;
        } else if (cell == 4) {
          type = BrickType.unbreakable;
          maxHealth = 1;
        }

        bricks.add(
          Brick(
            rect: rect,
            type: type,
            maxHealth: maxHealth,
          ),
        );
      }
    }

    return bricks;
  }
}
