import 'dart:ui';
import 'package:flutter/material.dart';
import '../../game_manager.dart';

class GameOverOverlay extends StatelessWidget {
  final GameManager manager;
  final VoidCallback onRestart;
  final VoidCallback onExitToMenu;

  const GameOverOverlay({
    super.key,
    required this.manager,
    required this.onRestart,
    required this.onExitToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return _FrostedContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "GAME OVER",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 38.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 3.0,
              shadows: [
                Shadow(color: Colors.red, blurRadius: 15.0),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          _StatRow(label: "Score", value: "${manager.score}"),
          const SizedBox(height: 8.0),
          _StatRow(label: "High Score", value: "${manager.highScore}"),
          const SizedBox(height: 8.0),
          _StatRow(label: "Coins Collected", value: "+${manager.coins}"),
          const SizedBox(height: 32.0),
          _NeonButton(
            text: "PLAY AGAIN",
            color: Colors.cyanAccent,
            onPressed: onRestart,
          ),
          const SizedBox(height: 12.0),
          _NeonButton(
            text: "MAIN MENU",
            color: Colors.white70,
            onPressed: onExitToMenu,
          ),
        ],
      ),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExitToMenu;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExitToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return _FrostedContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "PAUSED",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 34.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 3.0,
              shadows: [
                Shadow(color: Colors.amber, blurRadius: 15.0),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
          _NeonButton(
            text: "RESUME",
            color: Colors.greenAccent,
            onPressed: onResume,
          ),
          const SizedBox(height: 12.0),
          _NeonButton(
            text: "RESTART",
            color: Colors.pinkAccent,
            onPressed: onRestart,
          ),
          const SizedBox(height: 12.0),
          _NeonButton(
            text: "MAIN MENU",
            color: Colors.white70,
            onPressed: onExitToMenu,
          ),
        ],
      ),
    );
  }
}

class LevelCompleteOverlay extends StatelessWidget {
  final GameManager manager;
  final VoidCallback onNextLevel;
  final VoidCallback onExitToMenu;

  const LevelCompleteOverlay({
    super.key,
    required this.manager,
    required this.onNextLevel,
    required this.onExitToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return _FrostedContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "LEVEL COMPLETE",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 34.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              shadows: [
                Shadow(color: Colors.green, blurRadius: 15.0),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          _StatRow(label: "Current Score", value: "${manager.score}"),
          const SizedBox(height: 8.0),
          _StatRow(label: "Level Cleared", value: "${manager.level}"),
          const SizedBox(height: 8.0),
          _StatRow(label: "Win Bonus", value: "+${manager.level * 25} Coins"),
          const SizedBox(height: 32.0),
          _NeonButton(
            text: "NEXT LEVEL",
            color: Colors.cyanAccent,
            onPressed: onNextLevel,
          ),
          const SizedBox(height: 12.0),
          _NeonButton(
            text: "MAIN MENU",
            color: Colors.white70,
            onPressed: onExitToMenu,
          ),
        ],
      ),
    );
  }
}

class MenuOverlay extends StatelessWidget {
  final GameManager manager;
  final VoidCallback onStart;
  final VoidCallback onOpenShop;
  final VoidCallback onOpenLevelSelect;
  final VoidCallback onOpenAchievements;
  final VoidCallback onToggleMode;

  const MenuOverlay({
    super.key,
    required this.manager,
    required this.onStart,
    required this.onOpenShop,
    required this.onOpenLevelSelect,
    required this.onOpenAchievements,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    String scoreText = manager.isEndlessMode
        ? "Endless Best: ${manager.endlessHighScore}"
        : "Campaign Best: ${manager.highScore}";

    return _FrostedContainer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "NEON",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 48.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 4.0,
                shadows: [
                  Shadow(color: Colors.cyan, blurRadius: 20.0),
                ],
              ),
            ),
            const Text(
              "BREAKOUT",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 36.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 6.0,
                shadows: [
                  Shadow(color: Colors.pink, blurRadius: 20.0),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "$scoreText  |  👛 Coins: ${manager.coins}",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            
            // Mode Toggle Selector Button
            InkWell(
              onTap: onToggleMode,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: manager.isEndlessMode ? Colors.purpleAccent : Colors.cyanAccent,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      manager.isEndlessMode ? Icons.all_inclusive : Icons.map_outlined,
                      color: manager.isEndlessMode ? Colors.purpleAccent : Colors.cyanAccent,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      manager.isEndlessMode ? "MODE: ENDLESS" : "MODE: CAMPAIGN",
                      style: TextStyle(
                        color: manager.isEndlessMode ? Colors.purpleAccent : Colors.cyanAccent,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24.0),
            _NeonButton(
              text: "START GAME",
              color: Colors.cyanAccent,
              onPressed: onStart,
            ),
            if (!manager.isEndlessMode) ...[
              const SizedBox(height: 12.0),
              _NeonButton(
                text: "SELECT MAP",
                color: Colors.purpleAccent,
                onPressed: onOpenLevelSelect,
              ),
            ],
            const SizedBox(height: 12.0),
            _NeonButton(
              text: "COSMETIC SHOP",
              color: Colors.amberAccent,
              onPressed: onOpenShop,
            ),
            const SizedBox(height: 12.0),
            _NeonButton(
              text: "ACHIEVEMENTS",
              color: Colors.pinkAccent,
              onPressed: onOpenAchievements,
            ),
            const SizedBox(height: 28.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: const Column(
                children: [
                  Text(
                    "HOW TO PLAY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 6.0),
                  Text(
                    "Drag paddle left & right to bounce the ball.\nCollect gold coins to purchase shop cosmetics!\nCatch glowing pills for active power-ups.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.0,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelSelectOverlay extends StatelessWidget {
  final GameManager manager;
  final ValueChanged<int> onSelectLevel;
  final VoidCallback onClose;

  const LevelSelectOverlay({
    super.key,
    required this.manager,
    required this.onSelectLevel,
    required this.onClose,
  });

  static const List<String> levelNames = [
    "Standard Grid",
    "Neon Heart",
    "Neon Pyramid",
    "Double Towers",
    "Checkerboard",
    "Defensive Wall",
    "Space Invader",
    "Spiral Tunnel",
    "Diamond Defense",
    "Hourglass Funnel",
    "Bomb Zone",
    "Warp Columns",
    "Minefield",
    "The Maze",
    "Hourglass Chambers",
    "The Cage",
    "Zig-Zag Fortress",
    "Crossfire Maze",
    "Iron Fortress",
    "The Grand Finale",
  ];

  @override
  Widget build(BuildContext context) {
    return _FrostedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      width: 320.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.map_outlined, color: Colors.purpleAccent, size: 24.0),
                  SizedBox(width: 8.0),
                  Text(
                    "SELECT MAP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: onClose,
              ),
            ],
          ),
          
          // Dev Mode Badge
          if (GameManager.isDevMode)
            Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bug_report, size: 12.0, color: Colors.amberAccent),
                  SizedBox(width: 4.0),
                  Text(
                    "DEV MODE: ALL UNLOCKED",
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8.0),
          
          // Scrollable Tiers & Levels List
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTierSection("TIER 1: BASICS", 1, 5, Colors.cyanAccent),
                    const SizedBox(height: 16.0),
                    _buildTierSection("TIER 2: SHIELDS", 6, 10, Colors.blueAccent),
                    const SizedBox(height: 16.0),
                    _buildTierSection("TIER 3: HAZARDS", 11, 15, Colors.purpleAccent),
                    const SizedBox(height: 16.0),
                    _buildTierSection("TIER 4: CHAOS", 16, 20, Colors.redAccent),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSection(String tierName, int startLevel, int endLevel, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            tierName,
            style: TextStyle(
              color: themeColor,
              fontSize: 12.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (endLevel - startLevel) + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 8.0),
          itemBuilder: (context, index) {
            int lvl = startLevel + index;
            bool isUnlocked = GameManager.isDevMode || lvl <= manager.maxUnlockedLevel;
            String name = levelNames[lvl - 1];

            return InkWell(
              onTap: isUnlocked ? () => onSelectLevel(lvl) : null,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.white.withOpacity(0.04)
                      : Colors.white.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: isUnlocked
                        ? themeColor.withOpacity(0.25)
                        : Colors.white.withOpacity(0.05),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Level $lvl",
                            style: TextStyle(
                              color: isUnlocked ? Colors.white70 : Colors.white38,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            name,
                            style: TextStyle(
                              color: isUnlocked ? Colors.white : Colors.white30,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      const Icon(Icons.lock, size: 16.0, color: Colors.white30)
                    else
                      Icon(Icons.arrow_forward_ios, size: 12.0, color: themeColor.withOpacity(0.7)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AchievementsOverlay extends StatelessWidget {
  final GameManager manager;
  final VoidCallback onClose;

  const AchievementsOverlay({
    super.key,
    required this.manager,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _FrostedContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: onClose,
              ),
              const Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "ACHIEVEMENTS",
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(color: Colors.pink, blurRadius: 10.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48.0),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            "Unlocked: ${manager.unlockedAchievements.length} / 4",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildAchievementItem(
                  id: "combo_king",
                  name: "Combo King",
                  desc: "Reach a combo multiplier of 12x or higher.",
                  reward: 100,
                  color: Colors.amberAccent,
                ),
                _buildAchievementItem(
                  id: "perfect_clear",
                  name: "Perfect Clear",
                  desc: "Complete any level without losing a single life.",
                  reward: 100,
                  color: Colors.cyanAccent,
                ),
                _buildAchievementItem(
                  id: "demolitionist",
                  name: "Demolitionist",
                  desc: "Destroy 3 or more bricks in a single splash damage explosion.",
                  reward: 100,
                  color: Colors.orangeAccent,
                ),
                _buildAchievementItem(
                  id: "drone_hunter",
                  name: "Drone Hunter",
                  desc: "Shoot down 5 active flying drone enemies in a single run.",
                  reward: 100,
                  color: Colors.pinkAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required String id,
    required String name,
    required String desc,
    required int reward,
    required Color color,
  }) {
    bool isUnlocked = manager.unlockedAchievements.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isUnlocked ? color.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : Colors.white.withOpacity(0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? Icons.emoji_events : Icons.emoji_events_outlined,
              color: isUnlocked ? color : Colors.white24,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : Colors.white38,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  desc,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white60 : Colors.white24,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isUnlocked ? "UNLOCKED" : "LOCKED",
                style: TextStyle(
                  color: isUnlocked ? Colors.greenAccent : Colors.white24,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                "+$reward Coins",
                style: TextStyle(
                  color: isUnlocked ? Colors.amberAccent : Colors.white24,
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShopOverlay extends StatelessWidget {
  final GameManager manager;
  final VoidCallback onClose;

  const ShopOverlay({
    super.key,
    required this.manager,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return _FrostedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      width: 320.0,
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Coin count and Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      "👛 ",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      "${manager.coins} COINS",
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
            const Text(
              "NEON SHOP",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: Colors.cyan, blurRadius: 10.0),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            // Custom Neon styled TabBar
            const TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: "PADDLES"),
                Tab(text: "BALLS"),
              ],
            ),
            const SizedBox(height: 16.0),
            // Tab contents
            SizedBox(
              height: 250.0,
              child: TabBarView(
                children: [
                  // Tab 1: Paddles
                  ListenableBuilder(
                    listenable: manager,
                    builder: (context, child) {
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          _buildShopItem(
                            id: 'paddle_pink',
                            name: "Neon Pink",
                            desc: "Standard neon pink glide trail.",
                            cost: 0,
                            color: const Color(0xFFFF007F),
                            category: 'paddle',
                            isPaddle: true,
                          ),
                          _buildShopItem(
                            id: 'paddle_green',
                            name: "Neo Green",
                            desc: "Leaves a retro green dust trail.",
                            cost: 100,
                            color: Colors.greenAccent,
                            category: 'paddle',
                            isPaddle: true,
                          ),
                          _buildShopItem(
                            id: 'paddle_gold',
                            name: "Gold Sparkle",
                            desc: "Emits sparkling gold stars on drag.",
                            cost: 250,
                            color: Colors.amberAccent,
                            category: 'paddle',
                            isPaddle: true,
                          ),
                        ],
                      );
                    },
                  ),
                  // Tab 2: Balls
                  ListenableBuilder(
                    listenable: manager,
                    builder: (context, child) {
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          _buildShopItem(
                            id: 'ball_white',
                            name: "Classic White",
                            desc: "Standard glowing energy orb.",
                            cost: 0,
                            color: Colors.white,
                            category: 'ball',
                            isPaddle: false,
                          ),
                          _buildShopItem(
                            id: 'ball_cyan',
                            name: "Plasma Cyan",
                            desc: "Cyan glow + leaves energy trails.",
                            cost: 100,
                            color: Colors.cyanAccent,
                            category: 'ball',
                            isPaddle: false,
                          ),
                          _buildShopItem(
                            id: 'ball_orange',
                            name: "Fiery Orange",
                            desc: "FIREBALL: Breaks armored bricks in 1 hit + splash damage!",
                            cost: 250,
                            color: Colors.orangeAccent,
                            category: 'ball',
                            isPaddle: false,
                          ),
                          _buildShopItem(
                            id: 'ball_purple',
                            name: "Magnet Purple",
                            desc: "MAGNET PULSE: Gently pulls ball towards paddle at the bottom!",
                            cost: 400,
                            color: Colors.purpleAccent,
                            category: 'ball',
                            isPaddle: false,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem({
    required String id,
    required String name,
    required String desc,
    required int cost,
    required Color color,
    required String category,
    required bool isPaddle,
  }) {
    bool unlocked = manager.isUnlocked(id);
    bool equipped = (category == 'paddle' && manager.equippedPaddle == id) ||
                    (category == 'ball' && manager.equippedBall == id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: equipped ? color.withOpacity(0.4) : Colors.white.withOpacity(0.06),
          width: equipped ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Graphic Preview box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Center(
              child: isPaddle
                  ? Container(
                      width: 28,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3.0),
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.5), blurRadius: 4.0),
                        ],
                      ),
                    )
                  : Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.6), blurRadius: 5.0),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10.0),
          // Info descriptions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6.0),
          // Actions Buttons (Buy, Equip, Equipped)
          _buildItemActionButton(id, cost, unlocked, equipped, color, category),
        ],
      ),
    );
  }

  Widget _buildItemActionButton(
    String id,
    int cost,
    bool unlocked,
    bool equipped,
    Color color,
    String category,
  ) {
    if (equipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          "ACTIVE",
          style: TextStyle(
            color: color,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (unlocked) {
      return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.06),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          minimumSize: Size.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        onPressed: () => manager.equipCosmetic(id, category),
        child: const Text(
          "EQUIP",
          style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
        ),
      );
    }

    // Locked - requires buying
    bool canAfford = manager.coins >= cost;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: canAfford ? Colors.amberAccent : Colors.white12,
        foregroundColor: canAfford ? Colors.black : Colors.white30,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
      ),
      onPressed: canAfford ? () => manager.buyCosmetic(id, cost) : null,
      child: Text(
        "$cost xu",
        style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.w900),
      ),
    );
  }
}

// Frosted container configurations
class _FrostedContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;

  const _FrostedContainer({
    required this.child,
    this.width = 300.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            width: width,
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFF161522).withOpacity(0.75),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15.0,
                  spreadRadius: 2.0,
                )
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _NeonButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _NeonButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F0E17),
          foregroundColor: color,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          side: BorderSide(color: color, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            shadows: [
              Shadow(color: color.withOpacity(0.5), blurRadius: 4.0),
            ],
          ),
        ),
      ),
    );
  }
}
