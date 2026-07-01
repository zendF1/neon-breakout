import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/ball.dart';
import 'models/paddle.dart';
import 'models/brick.dart';
import 'models/power_up.dart';
import 'models/particle.dart';
import 'models/coin.dart';
import 'models/hazard.dart';
import 'physics.dart';
import 'level_manager.dart';
import 'audio_controller.dart';

enum GamePlayState { menu, playing, paused, gameOver, levelComplete }

class GameManager extends ChangeNotifier {
  GamePlayState state = GamePlayState.menu;

  static const bool isDevMode = true; // Set to true to unlock all 20 levels in developer mode
  int maxUnlockedLevel = 1;

  // Screen constraints
  double screenWidth = 360.0;
  double screenHeight = 640.0;

  // Game Entities
  late Paddle paddle;
  final List<Ball> balls = [];
  final List<Brick> bricks = [];
  final List<PowerUp> powerUps = [];
  final List<Coin> fallingCoins = [];
  final List<Hazard> fallingHazards = [];
  final ParticleSystem particleSystem = ParticleSystem();

  // Game Stats
  int score = 0;
  int highScore = 0;
  int lives = 3;
  int level = 1;
  int combo = 0;
  double comboTimer = 0.0;
  int coins = 0; // Total economy coins

  // Juice & Effects
  double shakeIntensity = 0.0;
  Offset shakeOffset = Offset.zero;

  // Power-up & Hazard timers
  double widePaddleTimer = 0.0;
  double slowMotionTimer = 0.0;
  double glitchTimer = 0.0;

  // Floating score and coin texts
  final List<FloatingText> floatingTexts = [];

  // Cosmetics & Shop States
  String equippedPaddle = 'paddle_pink';
  String equippedBall = 'ball_white';
  List<String> unlockedItems = ['paddle_pink', 'ball_white'];

  final AudioController audio = AudioController();
  final math.Random _random = math.Random();

  // Drag tracking for paddle motion dust
  double _lastPaddleX = 0.0;

  GameManager() {
    paddle = Paddle(positionX: screenWidth / 2);
    resetGame();
    audio.init();
    loadSavedData();
  }

  void initializeScreen(double width, double height) {
    if (screenWidth == width && screenHeight == height) return;
    screenWidth = width;
    screenHeight = height;
    
    paddle.positionX = screenWidth / 2;
    if (state == GamePlayState.menu) {
      resetGame();
    }
  }

  // --- Persistence Methods (shared_preferences) ---
  Future<void> loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      highScore = prefs.getInt('highScore') ?? 0;
      coins = prefs.getInt('coins') ?? 0;
      maxUnlockedLevel = prefs.getInt('maxUnlockedLevel') ?? 1;
      equippedPaddle = prefs.getString('equippedPaddle') ?? 'paddle_pink';
      equippedBall = prefs.getString('equippedBall') ?? 'ball_white';
      unlockedItems = prefs.getStringList('unlockedItems') ?? ['paddle_pink', 'ball_white'];
      
      // Sync cosmetics to models
      _applyCosmeticsToModels();
      notifyListeners();
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> saveGameStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore);
      await prefs.setInt('coins', coins);
      await prefs.setInt('maxUnlockedLevel', maxUnlockedLevel);
      await prefs.setString('equippedPaddle', equippedPaddle);
      await prefs.setString('equippedBall', equippedBall);
      await prefs.setStringList('unlockedItems', unlockedItems);
    } catch (e) {
      // Fail silently
    }
  }

  Ball _createBall({required Offset position, required Offset velocity}) {
    Color ballColor = Colors.white;
    Color ballGlow = const Color(0x99FFFFFF);
    
    if (equippedBall == 'ball_cyan') {
      ballColor = Colors.cyanAccent;
      ballGlow = Colors.cyan.withOpacity(0.6);
    } else if (equippedBall == 'ball_orange') {
      ballColor = Colors.orangeAccent;
      ballGlow = Colors.orange.withOpacity(0.6);
    }
    
    return Ball(
      position: position,
      velocity: velocity,
      color: ballColor,
      glowColor: ballGlow,
    );
  }

  void _applyCosmeticsToModels() {
    // Paddle Colors
    if (equippedPaddle == 'paddle_green') {
      paddle = Paddle(
        positionX: paddle.positionX,
        color: Colors.greenAccent,
        glowColor: Colors.green.withOpacity(0.5),
      );
    } else if (equippedPaddle == 'paddle_gold') {
      paddle = Paddle(
        positionX: paddle.positionX,
        color: Colors.amberAccent,
        glowColor: Colors.amber.withOpacity(0.5),
      );
    } else {
      paddle = Paddle(
        positionX: paddle.positionX,
        color: const Color(0xFFFF007F), // Neon Pink
        glowColor: const Color(0x99FF007F),
      );
    }

    // Ball Colors
    Color ballColor = Colors.white;
    Color ballGlow = const Color(0x99FFFFFF);
    if (equippedBall == 'ball_cyan') {
      ballColor = Colors.cyanAccent;
      ballGlow = Colors.cyan.withOpacity(0.6);
    } else if (equippedBall == 'ball_orange') {
      ballColor = Colors.orangeAccent;
      ballGlow = Colors.orange.withOpacity(0.6);
    }

    for (var ball in balls) {
      ball.color = ballColor;
      ball.glowColor = ballGlow;
    }

    // Apply speed scaling & width scaling to current models
    _applyDifficultyScaling();
  }

  void _applyDifficultyScaling() {
    // 1. Shrink paddle width based on level (5% per level, clamp to minimum 70%)
    double widthMultiplier = math.max(0.70, 1.0 - (level - 1) * 0.05);
    
    // If wide paddle is active, override it
    if (widePaddleTimer > 0) {
      paddle.setWidthMultiplier(widthMultiplier * 1.6);
    } else {
      paddle.setWidthMultiplier(widthMultiplier);
    }

    // 2. Base Ball Speed scales with level (+35 pixels per second per level)
    double baseSpeed = 320.0 + (level - 1) * 35.0;
    
    for (var ball in balls) {
      ball.baseSpeed = baseSpeed;
      // Re-apply speed modifications
      if (slowMotionTimer > 0) {
        ball.setSpeed(0.6);
      } else {
        ball.setSpeed(1.0);
      }
    }
  }

  // --- Shop Business Logic ---
  bool isUnlocked(String id) => unlockedItems.contains(id);

  bool buyCosmetic(String id, int cost) {
    if (coins >= cost && !isUnlocked(id)) {
      coins -= cost;
      unlockedItems.add(id);
      saveGameStats();
      audio.playSFX('buff');
      notifyListeners();
      return true;
    }
    return false;
  }

  void equipCosmetic(String id, String category) {
    if (!isUnlocked(id)) return;
    if (category == 'paddle') {
      equippedPaddle = id;
    } else if (category == 'ball') {
      equippedBall = id;
    }
    saveGameStats();
    _applyCosmeticsToModels();
    audio.playSFX('hit');
    notifyListeners();
  }

  // --- Core Game Loops & State changes ---
  void resetGame() {
    score = 0;
    lives = 3;
    level = 1;
    combo = 0;
    comboTimer = 0.0;
    shakeIntensity = 0.0;
    shakeOffset = Offset.zero;
    widePaddleTimer = 0.0;
    slowMotionTimer = 0.0;
    glitchTimer = 0.0;
    
    fallingCoins.clear();
    fallingHazards.clear();
    balls.clear();
    bricks.clear();
    powerUps.clear();
    floatingTexts.clear();
    
    _applyCosmeticsToModels();
    
    // Initial ball placement
    balls.add(_createBall(
      position: Offset(screenWidth / 2, screenHeight - 90.0),
      velocity: const Offset(150.0, -250.0),
    ));

    _applyDifficultyScaling();
    
    bricks.addAll(LevelManager.buildLevel(level, screenWidth));
    notifyListeners();
  }

  void startGame() {
    audio.stopBGM().then((_) {
      audio.playBGM();
    });
    state = GamePlayState.playing;
    _lastPaddleX = paddle.positionX;
    notifyListeners();
  }

  void pauseGame() {
    if (state == GamePlayState.playing) {
      state = GamePlayState.paused;
      audio.pauseBGM();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (state == GamePlayState.paused) {
      state = GamePlayState.playing;
      audio.resumeBGM();
      notifyListeners();
    }
  }

  void exitToMenu() {
    state = GamePlayState.menu;
    audio.stopBGM();
    notifyListeners();
  }

  void nextLevel() {
    level++;
    combo = 0;
    comboTimer = 0.0;
    widePaddleTimer = 0.0;
    slowMotionTimer = 0.0;
    glitchTimer = 0.0;
    
    balls.clear();
    powerUps.clear();
    fallingCoins.clear();
    fallingHazards.clear();
    
    balls.add(_createBall(
      position: Offset(screenWidth / 2, screenHeight - 90.0),
      velocity: Offset(120.0 + _random.nextDouble() * 60, -260.0),
    ));

    _applyCosmeticsToModels();
    
    bricks.clear();
    bricks.addAll(LevelManager.buildLevel(level, screenWidth));
    
    state = GamePlayState.playing;
    audio.playBGM();
    notifyListeners();
  }

  void selectLevel(int selectedLevel) {
    score = 0;
    lives = 3;
    level = selectedLevel;
    combo = 0;
    comboTimer = 0.0;
    shakeIntensity = 0.0;
    shakeOffset = Offset.zero;
    widePaddleTimer = 0.0;
    slowMotionTimer = 0.0;
    glitchTimer = 0.0;
    
    fallingCoins.clear();
    fallingHazards.clear();
    balls.clear();
    bricks.clear();
    powerUps.clear();
    floatingTexts.clear();
    
    _applyCosmeticsToModels();
    balls.add(_createBall(
      position: Offset(screenWidth / 2, screenHeight - 90.0),
      velocity: const Offset(150.0, -250.0),
    ));

    _applyDifficultyScaling();
    
    bricks.clear();
    bricks.addAll(LevelManager.buildLevel(level, screenWidth));
    
    state = GamePlayState.playing;
    audio.stopBGM().then((_) {
      audio.playBGM();
    });
    notifyListeners();
  }

  void handlePaddleDrag(double deltaX) {
    if (state != GamePlayState.playing) return;
    paddle.move(deltaX, screenWidth);
  }

  /// Update physics, entities, particle trails, and time modifiers on every frame
  void update(double deltaTime) {
    if (state != GamePlayState.playing) {
      particleSystem.update(deltaTime);
      _updateFloatingTexts(deltaTime);
      return;
    }

    // 1. Screen Shake Decay
    if (shakeIntensity > 0) {
      shakeIntensity -= deltaTime * 15.0;
      if (shakeIntensity < 0) shakeIntensity = 0;
      double dx = (_random.nextDouble() * 2 - 1) * shakeIntensity;
      double dy = (_random.nextDouble() * 2 - 1) * shakeIntensity;
      shakeOffset = Offset(dx, dy);
    } else {
      shakeOffset = Offset.zero;
    }

    // 2. Timers Decrementation
    if (comboTimer > 0) {
      comboTimer -= deltaTime;
      if (comboTimer <= 0) combo = 0;
    }

    if (widePaddleTimer > 0) {
      widePaddleTimer -= deltaTime;
      if (widePaddleTimer <= 0) {
        _applyDifficultyScaling(); // Reset to standard level-scaled width
        floatingTexts.add(FloatingText(
          text: "Paddle Normal",
          position: paddle.getRect(screenHeight).topCenter - const Offset(0, 10),
          color: Colors.redAccent,
        ));
      }
    }

    if (slowMotionTimer > 0) {
      slowMotionTimer -= deltaTime;
      if (slowMotionTimer <= 0) {
        _applyDifficultyScaling(); // Restore default speed
        floatingTexts.add(FloatingText(
          text: "Speed Normal",
          position: Offset(screenWidth / 2, screenHeight / 2),
          color: Colors.redAccent,
        ));
      }
    }

    if (glitchTimer > 0) {
      glitchTimer -= deltaTime;
      if (glitchTimer <= 0) {
        floatingTexts.add(FloatingText(
          text: "Glitch Resolved",
          position: Offset(screenWidth / 2, screenHeight / 2 + 40),
          color: Colors.greenAccent,
        ));
      }
    }

    // 3. Spawns Cosmetics Particle Trails
    _spawnCosmeticTrails(deltaTime);

    // 4. Update Particle System & Floating Texts
    particleSystem.update(deltaTime);
    _updateFloatingTexts(deltaTime);

    // 5. Update Falling Coins
    for (int i = fallingCoins.length - 1; i >= 0; i--) {
      var coin = fallingCoins[i];
      coin.update(deltaTime);

      // Check Paddle Collection
      Rect paddleRect = paddle.getRect(screenHeight);
      if (coin.getRect().overlaps(paddleRect)) {
        _collectCoin(coin);
        fallingCoins.removeAt(i);
        continue;
      }

      // Check Out of Bounds
      if (coin.position.dy > screenHeight) {
        fallingCoins.removeAt(i);
      }
    }

    // 6. Update Power-ups
    for (int i = powerUps.length - 1; i >= 0; i--) {
      var powerUp = powerUps[i];
      powerUp.update(deltaTime);

      Rect paddleRect = paddle.getRect(screenHeight);
      if (powerUp.getRect().overlaps(paddleRect)) {
        _collectPowerUp(powerUp);
        powerUps.removeAt(i);
        continue;
      }

      if (powerUp.position.dy > screenHeight) {
        powerUps.removeAt(i);
      }
    }

    // 6b. Update Falling Hazards (Bombs & Glitch Orbs)
    for (int i = fallingHazards.length - 1; i >= 0; i--) {
      var hazard = fallingHazards[i];
      hazard.update(deltaTime);

      Rect paddleRect = paddle.getRect(screenHeight);
      if (hazard.getRect().overlaps(paddleRect)) {
        if (hazard.type == HazardType.bomb) {
          lives--;
          triggerShake(15.0);
          combo = 0;
          audio.playSFX('lose'); // Explosion audio cue
          
          floatingTexts.add(FloatingText(
            text: "!!! BOMB !!!",
            position: paddle.getRect(screenHeight).topCenter - const Offset(0, 15),
            color: Colors.redAccent,
          ));

          particleSystem.spawnExplosion(hazard.position, Colors.redAccent, count: 22);
          particleSystem.spawnExplosion(hazard.position, Colors.orangeAccent, count: 8);

          if (lives <= 0) {
            state = GamePlayState.gameOver;
            audio.stopBGM();
            if (score > highScore) {
              highScore = score;
            }
            saveGameStats();
          }
        } else if (hazard.type == HazardType.glitch) {
          glitchTimer = 7.0;
          audio.playSFX('buff'); // Warp/glitch audio cue
          
          floatingTexts.add(FloatingText(
            text: "GLITCH TRAJECTORY!",
            position: paddle.getRect(screenHeight).topCenter - const Offset(0, 15),
            color: Colors.purpleAccent,
          ));

          particleSystem.spawnExplosion(hazard.position, Colors.purpleAccent, count: 18);
        }
        fallingHazards.removeAt(i);
        continue;
      }

      if (hazard.position.dy > screenHeight) {
        fallingHazards.removeAt(i);
      }
    }

    // 7. Update Balls, Physics & Collisions
    for (int i = balls.length - 1; i >= 0; i--) {
      var ball = balls[i];
      ball.update(deltaTime);

      // Boundary Collisions
      String? boundaryHit = PhysicsEngine.checkBoundaryCollision(ball, screenWidth, screenHeight);
      if (boundaryHit == 'left' || boundaryHit == 'right' || boundaryHit == 'top') {
        audio.playSFX('hit');
        particleSystem.spawnExplosion(ball.position, ball.color.withOpacity(0.25), count: 3);
        if (glitchTimer > 0) {
          _applyGlitchDeflection(ball);
        }
      } else if (boundaryHit == 'lost') {
        balls.removeAt(i);
        audio.playSFX('lose');
        continue;
      }

      // Paddle Collision
      bool hitPaddle = PhysicsEngine.checkPaddleCollision(ball, paddle, screenHeight);
      if (hitPaddle) {
        combo = 0; // Break combo
        triggerShake(2.5);
        audio.playSFX('hit');
        particleSystem.spawnExplosion(
          ball.position + Offset(0, ball.radius),
          paddle.color,
          count: 8,
        );
        if (glitchTimer > 0) {
          _applyGlitchDeflection(ball);
        }
      }

      // Brick Collisions
      for (var brick in bricks) {
        if (brick.isDestroyed) continue;
        
        bool hitBrick = PhysicsEngine.checkBrickCollision(ball, brick);
        if (hitBrick) {
          triggerShake(3.0);
          audio.playSFX('hit');
          bool destroyed = brick.hit();
          
          if (destroyed) {
            _handleBrickDestruction(brick);
          } else {
            particleSystem.spawnExplosion(ball.position, brick.color, count: 5);
          }
          if (glitchTimer > 0) {
            _applyGlitchDeflection(ball);
          }
          break;
        }
      }
    }

    // 8. Ball Loss & Lives Handler
    if (balls.isEmpty) {
      lives--;
      triggerShake(12.0);
      combo = 0;
      audio.playSFX('lose');
      
      if (lives <= 0) {
        state = GamePlayState.gameOver;
        audio.stopBGM();
        if (score > highScore) {
          highScore = score;
        }
        saveGameStats();
      } else {
        // Reset single ball
        balls.add(_createBall(
          position: Offset(screenWidth / 2, screenHeight - 90.0),
          velocity: Offset(150.0 * (_random.nextBool() ? 1 : -1), -250.0),
        ));
        paddle.positionX = screenWidth / 2;
        widePaddleTimer = 0.0;
        slowMotionTimer = 0.0;
        _applyCosmeticsToModels(); // restore scales
      }
    }

    // 9. Check Level Complete
    if (bricks.where((b) => b.type != BrickType.unbreakable).every((b) => b.isDestroyed)) {
      state = GamePlayState.levelComplete;
      audio.stopBGM();
      audio.playSFX('win');
      
      // Unlock next level
      maxUnlockedLevel = math.max(maxUnlockedLevel, level + 1);
      
      // Award bonus coins for completing level: level * 25 coins
      int bonusCoins = level * 25;
      coins += bonusCoins;
      saveGameStats();
      
      floatingTexts.add(FloatingText(
        text: "+$bonusCoins Win Bonus Coins!",
        position: Offset(screenWidth / 2, screenHeight / 2 - 40),
        color: Colors.amberAccent,
        life: 2.0,
      ));
    }

    notifyListeners();
  }

  void _applyGlitchDeflection(Ball ball) {
    // Add random reflection angle offset of [-15, +15] degrees in radians
    double angleRad = (_random.nextDouble() - 0.5) * 2 * (15 * math.pi / 180.0);
    double speed = ball.velocity.distance;
    double currentHeading = ball.velocity.direction;
    double newHeading = currentHeading + angleRad;
    ball.velocity = Offset(math.cos(newHeading) * speed, math.sin(newHeading) * speed);
    
    // Spawn glitchy purple sparks
    particleSystem.spawnExplosion(ball.position, Colors.purpleAccent, count: 6);
  }

  void _spawnCosmeticTrails(double deltaTime) {
    // Ball Particle Trails
    for (var ball in balls) {
      if (equippedBall == 'ball_cyan') {
        // Plasma Cyan: cyan dust tail
        if (_random.nextDouble() < 0.25) {
          particleSystem.particles.add(Particle(
            position: ball.position - (ball.velocity * 0.03),
            velocity: Offset((_random.nextDouble() - 0.5) * 20.0, (_random.nextDouble() - 0.5) * 20.0),
            color: Colors.cyanAccent.withOpacity(0.5),
            size: 2.0 + _random.nextDouble() * 2.0,
            lifetimeSeconds: 0.35,
          ));
        }
      } else if (equippedBall == 'ball_orange') {
        // Fiery Orange: orange/red flame trail
        if (_random.nextDouble() < 0.35) {
          particleSystem.particles.add(Particle(
            position: ball.position - (ball.velocity * 0.02),
            velocity: Offset((_random.nextDouble() - 0.5) * 15.0, (_random.nextDouble() - 0.5) * 15.0),
            color: _random.nextBool() ? Colors.orangeAccent : Colors.redAccent,
            size: 3.0 + _random.nextDouble() * 2.5,
            lifetimeSeconds: 0.4,
          ));
        }
      }
    }

    // Paddle Particle Trails (spawns when moving or sparkling)
    double dragDelta = (paddle.positionX - _lastPaddleX).abs();
    _lastPaddleX = paddle.positionX;

    if (equippedPaddle == 'paddle_green' && dragDelta > 0.5) {
      // Neo Green: Spawn trailing particles on move
      for (int i = 0; i < 2; i++) {
        double spawnX = paddle.positionX + (_random.nextDouble() - 0.5) * paddle.width;
        double spawnY = screenHeight - 65.0 - _random.nextDouble() * paddle.height;
        particleSystem.particles.add(Particle(
          position: Offset(spawnX, spawnY),
          velocity: Offset((_random.nextDouble() - 0.5) * 30.0, -10.0 - _random.nextDouble() * 30.0),
          color: Colors.greenAccent,
          size: 2.0 + _random.nextDouble() * 2.0,
          lifetimeSeconds: 0.4,
        ));
      }
    } else if (equippedPaddle == 'paddle_gold') {
      // Gold Sparkle: Idle & movement sparkling stars
      double spawnChance = dragDelta > 0.5 ? 0.4 : 0.08;
      if (_random.nextDouble() < spawnChance) {
        double spawnX = paddle.positionX + (_random.nextDouble() - 0.5) * paddle.width;
        double spawnY = screenHeight - 70.0;
        particleSystem.particles.add(Particle(
          position: Offset(spawnX, spawnY),
          velocity: Offset((_random.nextDouble() - 0.5) * 10.0, -20.0 - _random.nextDouble() * 30.0),
          color: Colors.amberAccent,
          size: 2.0 + _random.nextDouble() * 3.0,
          lifetimeSeconds: 0.5,
        ));
      }
    }
  }

  void _handleBrickDestruction(Brick brick) {
    score += 10;
    combo++;
    comboTimer = 2.5;

    // Award scores
    if (combo > 1) {
      score += combo * 2;
      floatingTexts.add(FloatingText(
        text: "+${10 + combo * 2} (x$combo Combo!)",
        position: brick.rect.center,
        color: Colors.amberAccent,
      ));
    } else {
      floatingTexts.add(FloatingText(
        text: "+10",
        position: brick.rect.center,
        color: Colors.cyanAccent,
      ));
    }

    particleSystem.spawnBrickDebris(brick.rect, brick.color, count: 12);

    // Explosive check
    if (brick.type == BrickType.explosive) {
      triggerShake(8.0);
      _triggerExplosion(brick.rect.center);
    }

    // 25% Coin Drop
    if (_random.nextDouble() < 0.25) {
      fallingCoins.add(Coin(position: brick.rect.center));
    }

    // 12% Power-Up Drop
    if (_random.nextDouble() < 0.12) {
      var types = PowerUpType.values;
      var randomType = types[_random.nextInt(types.length)];
      powerUps.add(PowerUp(
        position: brick.rect.center,
        type: randomType,
      ));
    }

    // If level >= 11, spawn falling hazards (10% Bomb, 10% Glitch Traps)
    if (level >= 11) {
      double randVal = _random.nextDouble();
      if (randVal < 0.10) {
        fallingHazards.add(Hazard(position: brick.rect.center, type: HazardType.bomb));
      } else if (randVal < 0.20) {
        fallingHazards.add(Hazard(position: brick.rect.center, type: HazardType.glitch));
      }
    }
  }

  void _triggerExplosion(Offset center) {
    double explosionRadius = 80.0;
    particleSystem.spawnExplosion(center, Colors.orangeAccent, count: 20);
    particleSystem.spawnExplosion(center, Colors.yellowAccent, count: 10);

    for (var otherBrick in bricks) {
      if (otherBrick.isDestroyed) continue;
      
      double distance = (otherBrick.rect.center - center).distance;
      if (distance <= explosionRadius) {
        bool destroyed = otherBrick.hit();
        if (destroyed) {
          _handleBrickDestruction(otherBrick);
        } else {
          particleSystem.spawnExplosion(otherBrick.rect.center, otherBrick.color, count: 5);
        }
      }
    }
  }

  void _collectCoin(Coin coin) {
    coins += 1;
    saveGameStats();
    audio.playSFX('coin');

    floatingTexts.add(FloatingText(
      text: "+1 Coin",
      position: paddle.getRect(screenHeight).topCenter - const Offset(0, 10),
      color: Colors.amberAccent,
    ));

    // Spawn tiny golden splash particles
    particleSystem.spawnExplosion(coin.position, Colors.amberAccent, count: 8);
  }

  void _collectPowerUp(PowerUp powerUp) {
    score += 50;
    audio.playSFX('buff');
    floatingTexts.add(FloatingText(
      text: "+50 Power-Up!",
      position: paddle.getRect(screenHeight).topCenter,
      color: powerUp.color,
    ));

    particleSystem.spawnExplosion(powerUp.position, powerUp.color, count: 15);

    switch (powerUp.type) {
      case PowerUpType.multiBall:
        if (balls.isNotEmpty) {
          Offset basePos = balls.first.position;
          balls.add(_createBall(
            position: basePos,
            velocity: const Offset(-210.0, -230.0),
          ));
          balls.add(_createBall(
            position: basePos,
            velocity: const Offset(210.0, -230.0),
          ));
        } else {
          balls.add(_createBall(
            position: Offset(screenWidth / 2, screenHeight - 90.0),
            velocity: const Offset(-210.0, -230.0),
          ));
          balls.add(_createBall(
            position: Offset(screenWidth / 2, screenHeight - 90.0),
            velocity: const Offset(210.0, -230.0),
          ));
        }
        _applyDifficultyScaling(); // Sync base speed multipliers
        break;

      case PowerUpType.widePaddle:
        widePaddleTimer = 8.0;
        _applyDifficultyScaling();
        break;

      case PowerUpType.slowMotion:
        slowMotionTimer = 8.0;
        _applyDifficultyScaling();
        break;
    }
  }

  void triggerShake(double intensity) {
    shakeIntensity = math.max(shakeIntensity, intensity);
  }

  void _updateFloatingTexts(double deltaTime) {
    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      var text = floatingTexts[i];
      text.life -= deltaTime * (text.life > 1.0 ? 0.8 : 1.5);
      text.position -= Offset(0, 30 * deltaTime);
      if (text.life <= 0) {
        floatingTexts.removeAt(i);
      }
    }
  }
}

class FloatingText {
  final String text;
  Offset position;
  double life;
  final Color color;

  FloatingText({
    required this.text,
    required this.position,
    this.life = 1.0,
    required this.color,
  });
}
