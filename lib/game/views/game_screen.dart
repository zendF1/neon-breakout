import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../game_manager.dart';
import 'game_painter.dart';
import 'overlays/game_overlays.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameManager _manager;
  late final Ticker _ticker;
  Duration _lastElapsedTime = Duration.zero;
  bool _isShopOpen = false;
  bool _isLevelSelectOpen = false;

  @override
  void initState() {
    super.initState();
    _manager = GameManager();

    // Setup 60fps Game Loop Ticker
    _ticker = createTicker((elapsed) {
      if (_lastElapsedTime == Duration.zero) {
        _lastElapsedTime = elapsed;
        return;
      }
      
      // Calculate delta time in seconds
      double deltaTime = (elapsed.inMicroseconds - _lastElapsedTime.inMicroseconds) / 1000000.0;
      _lastElapsedTime = elapsed;

      // Update game physics & model
      _manager.update(deltaTime);
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adapt engine bounds to match screen dimensions
            _manager.initializeScreen(constraints.maxWidth, constraints.maxHeight);

            return Stack(
              children: [
                // 1. Core Physics Canvas View
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    _manager.handlePaddleDrag(details.delta.dx);
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: GamePainter(manager: _manager),
                  ),
                ),

                // 2. HUD (Score, Level, Lives, Coins, Pause/Mute)
                _buildHUD(),

                // 3. Power-up Timers
                _buildPowerUpIndicators(),

                // 4. State overlays (Shop, Menu, Paused, GameOver, LevelComplete)
                ListenableBuilder(
                  listenable: _manager,
                  builder: (context, child) {
                    if (_isShopOpen) {
                      return ShopOverlay(
                        manager: _manager,
                        onClose: () {
                          setState(() {
                            _isShopOpen = false;
                          });
                        },
                      );
                    }

                    if (_isLevelSelectOpen) {
                      return LevelSelectOverlay(
                        manager: _manager,
                        onSelectLevel: (lvl) {
                          setState(() {
                            _isLevelSelectOpen = false;
                          });
                          _manager.selectLevel(lvl);
                        },
                        onClose: () {
                          setState(() {
                            _isLevelSelectOpen = false;
                          });
                        },
                      );
                    }

                    switch (_manager.state) {
                      case GamePlayState.menu:
                        return MenuOverlay(
                          manager: _manager,
                          onStart: _manager.startGame,
                          onOpenShop: () {
                            setState(() {
                              _isShopOpen = true;
                            });
                          },
                          onOpenLevelSelect: () {
                            setState(() {
                              _isLevelSelectOpen = true;
                            });
                          },
                        );
                      case GamePlayState.paused:
                        return PauseOverlay(
                          onResume: _manager.resumeGame,
                          onRestart: () {
                            _manager.resetGame();
                            _manager.startGame();
                          },
                          onExitToMenu: () {
                            _manager.resetGame();
                            _manager.exitToMenu();
                          },
                        );
                      case GamePlayState.gameOver:
                        return GameOverOverlay(
                          manager: _manager,
                          onRestart: () {
                            _manager.resetGame();
                            _manager.startGame();
                          },
                          onExitToMenu: () {
                            _manager.resetGame();
                            _manager.exitToMenu();
                          },
                        );
                      case GamePlayState.levelComplete:
                        return LevelCompleteOverlay(
                          manager: _manager,
                          onNextLevel: _manager.nextLevel,
                          onExitToMenu: () {
                            _manager.resetGame();
                            _manager.exitToMenu();
                          },
                        );
                      case GamePlayState.playing:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, child) {
        return Positioned(
          top: 10,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score, Combo & Coins count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "SCORE: ${_manager.score}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        "👛 ${_manager.coins}",
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_manager.combo > 1)
                    Text(
                      "COMBO x${_manager.combo}",
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                ],
              ),

              // Level, Lives, Mute & Pause
              Row(
                children: [
                  Text(
                    "LV. ${_manager.level}",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Render Heart Icons based on lives
                  ...List.generate(3, (index) {
                    bool hasLife = index < _manager.lives;
                    return Icon(
                      Icons.favorite,
                      size: 16.0,
                      color: hasLife ? Colors.pinkAccent : Colors.white24,
                    );
                  }),
                  const SizedBox(width: 8.0),
                  // Mute Button
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      _manager.audio.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white70,
                      size: 20.0,
                    ),
                    onPressed: () {
                      setState(() {
                        _manager.audio.toggleMute();
                      });
                    },
                  ),
                  const SizedBox(width: 6.0),
                  // Pause Button
                  if (_manager.state == GamePlayState.playing)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.pause, color: Colors.white70, size: 20.0),
                      onPressed: _manager.pauseGame,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPowerUpIndicators() {
    return ListenableBuilder(
      listenable: _manager,
      builder: (context, child) {
        if (_manager.state != GamePlayState.playing) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 90, // Place slightly above the paddle line
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_manager.widePaddleTimer > 0)
                _buildTimerBar(
                  label: "↔ WIDE PADDLE",
                  timer: _manager.widePaddleTimer,
                  color: Colors.blueAccent,
                ),
              if (_manager.slowMotionTimer > 0)
                const SizedBox(height: 6.0),
              if (_manager.slowMotionTimer > 0)
                _buildTimerBar(
                  label: "⏰ SLOW MOTION",
                  timer: _manager.slowMotionTimer,
                  color: Colors.cyanAccent,
                ),
              if (_manager.glitchTimer > 0)
                const SizedBox(height: 6.0),
              if (_manager.glitchTimer > 0)
                _buildTimerBar(
                  label: "⚡ GLITCH TRAJ.",
                  timer: _manager.glitchTimer,
                  color: Colors.purpleAccent,
                  maxDuration: 7.0,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerBar({
    required String label,
    required double timer,
    required Color color,
    double maxDuration = 8.0,
  }) {
    double progress = (timer / maxDuration).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6.0,
            ),
          ),
        ),
      ],
    );
  }
}
