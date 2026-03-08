import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:get_it/get_it.dart';
import '../game/snake_game.dart';
import 'tutorial_overlay.dart';
import 'pause_overlay.dart';
import 'hud/mg_card_puzzle_hud.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import '../utils/high_score_manager.dart';
import 'package:mg_common_game/core/ui/screens/leaderboard_screen.dart';
import 'package:mg_common_game/core/models/score_entry.dart';
import 'shop_screen.dart';
import 'game_over_overlay.dart';
import 'package:mg_common_game/systems/progression/prestige_manager.dart';
import 'package:mg_common_game/systems/progression/progression_manager.dart';
import 'package:mg_common_game/core/ui/screens/prestige_screen.dart';
import 'package:mg_common_game/systems/quests/daily_quest.dart';
import 'package:mg_common_game/core/ui/screens/daily_quest_screen.dart';
import 'package:mg_common_game/systems/quests/weekly_challenge.dart';
import 'package:mg_common_game/core/ui/screens/weekly_challenge_screen.dart';
import 'package:mg_common_game/systems/stats/statistics_manager.dart';
import 'package:mg_common_game/core/ui/screens/statistics_screen.dart';
import 'package:mg_common_game/systems/progression/achievement_manager.dart';
import 'package:mg_common_game/systems/settings/settings_manager.dart';
import 'package:mg_common_game/core/ui/screens/settings_screen.dart' as common;
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2d5016), // Dark Green
              Color(0xFF0a0f0a), // Almost Black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Game Title
                        const Text(
                          '스네이크',
                          style: TextStyle(
                            fontSize: 70, // Slightly reduced to fit Korean
                            fontWeight: FontWeight.bold,
                            color: MGColors.success, // Light Green
                            shadows: [
                              Shadow(
                                offset: Offset(4, 4),
                                blurRadius: 8,
                                color: MGColors.backgroundDarkDark.withValues(alpha: 0.45),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '게임',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: MGColors.textMediumEmphasis,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: MGColors.backgroundDarkDark.withValues(alpha: 0.45),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        const Text(
                          '모드 선택',
                          style: TextStyle(
                            color: MGColors.textMediumEmphasis,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Game Mode Cards
                        GameModeCard(
                          title: '일반',
                          description: '클래식 스네이크 게임',
                          icon: Icons.play_arrow,
                          color: MGColors.success,
                          onTap: () =>
                              _startGame(context, SnakeGameMode.normal),
                          highScoreFuture: HighScoreManager.getHighScore(
                            SnakeGameMode.normal.name,
                          ),
                        ),
                        GameModeCard(
                          title: '어려움',
                          description: '무작위 장애물이 등장합니다!',
                          icon: Icons.flash_on,
                          color: Colors.redAccent,
                          onTap: () => _startGame(context, SnakeGameMode.hard),
                          highScoreFuture: HighScoreManager.getHighScore(
                            SnakeGameMode.hard.name,
                          ),
                        ),
                        GameModeCard(
                          title: '타임 어택',
                          description: '제한 시간 내에 최고 점수를 노리세요!',
                          icon: Icons.timer,
                          color: Colors.orangeAccent,
                          onTap: () =>
                              _startGame(context, SnakeGameMode.timeAttack),
                          highScoreFuture: HighScoreManager.getHighScore(
                            SnakeGameMode.timeAttack.name,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Utilities Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // First row: Game utilities
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildUtilityButton(
                          context,
                          Icons.shopping_cart,
                          '상점',
                          () => _showShopScreen(context),
                        ),
                        _buildUtilityButton(
                          context,
                          Icons.emoji_events,
                          '랭킹',
                          () => _showLeaderboard(context),
                        ),
                        _buildUtilityButton(
                          context,
                          Icons.assignment_turned_in,
                          '일일 퀘스트',
                          () => _showDailyQuestsScreen(context),
                        ),
                        _buildUtilityButton(
                          context,
                          Icons.stars,
                          '주간 도전',
                          () => _showWeeklyChallengesScreen(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Second row: Settings and stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildUtilityButton(
                          context,
                          Icons.auto_awesome,
                          '환생',
                          () => _showPrestigeScreen(context),
                        ),
                        _buildUtilityButton(
                          context,
                          Icons.bar_chart,
                          '통계',
                          () => _showStatisticsScreen(context),
                        ),
                        _buildUtilityButton(
                          context,
                          Icons.settings,
                          '설정',
                          () => _showSettingsScreen(context),
                        ),
                        _buildUtilityButton(
                          context,
                          Icons.help_outline,
                          '게임 방법',
                          () => _showHowToPlay(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: MGColors.textHighEmphasis, size: 32),
          style: IconButton.styleFrom(
            backgroundColor: MGColors.textHighEmphasis.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: MGColors.textHighEmphasis,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _startGame(BuildContext context, SnakeGameMode mode) async {
    final hasSeenTutorial = await TutorialOverlay.hasSeenTutorial();

    if (!context.mounted) return;

    // Time Attack does not need tutorial usually, or share same tutorial.
    // Simplifying logic to just show tutorial if needed.

    if (!hasSeenTutorial) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameScreen(showTutorial: true, mode: mode),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameScreen(showTutorial: false, mode: mode),
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _showShopScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ShopScreen()));
  }

  Future<void> _showLeaderboard(BuildContext context) async {
    final normalScore = await HighScoreManager.getHighScore(
      SnakeGameMode.normal.name,
    );
    final hardScore = await HighScoreManager.getHighScore(
      SnakeGameMode.hard.name,
    );
    final timeAttackScore = await HighScoreManager.getHighScore(
      SnakeGameMode.timeAttack.name,
    );

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          title: '스네이크 랭킹',
          onClose: () => Navigator.of(context).pop(),
          onReset: () async {
            await HighScoreManager.resetAllHighScores();
          },
          scores: [
            ScoreEntry(
              label: '일반 모드',
              score: normalScore,
              iconAsset: 'assets/images/icon_play.png',
            ),
            ScoreEntry(
              label: '어려움 모드',
              score: hardScore,
              iconAsset: 'assets/images/icon_flash.png',
            ),
            ScoreEntry(
              label: '타임 어택',
              score: timeAttackScore,
              iconAsset: 'assets/images/icon_timer.png',
            ),
          ],
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: MGColors.success),
            SizedBox(width: 8),
            Text('게임 방법'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎮 조작법',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• 화면을 스와이프하여 방향 전환'),
            Text('• 화살표 키도 사용 가능'),
            Text('• 180도 회전 불가'),
            SizedBox(height: 16),
            Text(
              '🎯 목표',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('일반/어려움: 먹이를 먹고 성장하세요'),
            Text('타임 어택: 60초 안에 최고 점수!'),
            SizedBox(height: 16),
            Text(
              '⚠️ 게임 오버',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• 벽에 충돌'),
            Text('• 꼬리에 충돌'),
            Text('• 시간 초과 (타임 어택)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPrestigeScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PrestigeScreen(
          prestigeManager: GetIt.I<PrestigeManager>(),
          progressionManager: GetIt.I<ProgressionManager>(),
          title: '스네이크 환생',
          accentColor: MGColors.success,
          onClose: () => Navigator.of(context).pop(),
          onPrestige: () => _performPrestige(context),
        ),
      ),
    );
  }

  void _performPrestige(BuildContext context) {
    final prestigeManager = GetIt.I<PrestigeManager>();
    final progressionManager = GetIt.I<ProgressionManager>();

    final pointsGained = prestigeManager.performPrestige(
      progressionManager.currentLevel,
    );

    progressionManager.reset();

    final goldManager = GetIt.I<GoldManager>();
    goldManager.trySpendGold(goldManager.currentGold);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('환생 성공! $pointsGained 프레스티지 포인트를 얻었습니다!'),
        backgroundColor: MGColors.gold,
        duration: const Duration(seconds: 3),
      ),
    );

    setState(() {});
  }

  void _showDailyQuestsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyQuestScreen(
          questManager: GetIt.I<DailyQuestManager>(),
          title: '일일 퀘스트',
          accentColor: MGColors.success,
          onClaimReward: (questId, goldReward, xpReward) {
            final goldManager = GetIt.I<GoldManager>();
            final progressionManager = GetIt.I<ProgressionManager>();

            goldManager.addGold(goldReward);
            progressionManager.addXp(xpReward);
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showWeeklyChallengesScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WeeklyChallengeScreen(
          challengeManager: GetIt.I<WeeklyChallengeManager>(),
          title: '주간 도전',
          accentColor: MGColors.gold,
          onClaimReward: (challengeId, goldReward, xpReward, prestigeReward) {
            final goldManager = GetIt.I<GoldManager>();
            final progressionManager = GetIt.I<ProgressionManager>();
            final prestigeManager = GetIt.I<PrestigeManager>();

            goldManager.addGold(goldReward);
            progressionManager.addXp(xpReward);
            if (prestigeReward > 0) {
              prestigeManager.addPrestigePoints(prestigeReward);
            }
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showStatisticsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(
          statisticsManager: GetIt.I<StatisticsManager>(),
          progressionManager: GetIt.I<ProgressionManager>(),
          prestigeManager: GetIt.I<PrestigeManager>(),
          questManager: GetIt.I<DailyQuestManager>(),
          achievementManager: GetIt.I<AchievementManager>(),
          title: '통계',
          accentColor: MGColors.success,
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showSettingsScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => common.SettingsScreen(
          settingsManager: GetIt.I<SettingsManager>(),
          title: '설정',
          accentColor: MGColors.success,
          onClose: () => Navigator.of(context).pop(),
          version: '1.0.0',
        ),
      ),
    );
  }
}

class GameModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Future<int>? highScoreFuture;

  const GameModeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.highScoreFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: MGColors.textHighEmphasis,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MGColors.backgroundDarkDark.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: MGColors.backgroundDarkDark.withValues(alpha: 0.87),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(fontSize: 14, color: MGColors.common),
                      ),
                    ],
                  ),
                ),

                // High Score
                if (highScoreFuture != null)
                  FutureBuilder<int>(
                    future: highScoreFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data! > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: MGColors.gold,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: MGColors.gold),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 16,
                                color: MGColors.warning,
                              ),
                              Text(
                                '${snapshot.data}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: MGColors.warning,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool showTutorial;
  final SnakeGameMode mode;

  const GameScreen({super.key, required this.showTutorial, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SnakeGame _game;
  bool _showTutorial = false;
  bool _showPause = false;
  bool _showGameOver = false;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _game = SnakeGame(mode: widget.mode, onGameOver: _handleGameOver);
    _showTutorial = widget.showTutorial;
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    _highScore = await HighScoreManager.getHighScore(widget.mode.name);
  }

  void _handleGameOver() async {
    await _loadHighScore(); // Refresh high score (in case it was just updated)
    setState(() {
      _showGameOver = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),

          // MG Card Puzzle HUD (게임오버 아닐 때만)
          if (!_showTutorial && !_showPause && !_showGameOver)
            StreamBuilder<int>(
              stream: GetIt.I<GoldManager>().onGoldChanged,
              initialData: GetIt.I<GoldManager>().currentGold,
              builder: (context, snapshot) {
                return MGCardPuzzleHud(
                  score: _game.score,
                  highScore: _highScore,
                  length: _game.snake.length,
                  coins: snapshot.data ?? 0,
                  timeRemaining: widget.mode == SnakeGameMode.timeAttack
                      ? _game.remainingTime.toInt()
                      : null,
                  isPaused: false,
                  onPause: () {
                    _game.togglePause();
                    setState(() => _showPause = true);
                  },
                  onResume: null,
                );
              },
            ),

          // 일시정지 오버레이
          if (_showPause)
            PauseOverlay(
              onResume: () {
                _game.resume();
                setState(() => _showPause = false);
              },
              onRestart: () {
                _game.restart();
                setState(() {
                  _showPause = false;
                  _showGameOver = false;
                });
              },
              onMainMenu: () {
                Navigator.of(context).pop();
              },
            ),

          // Game Over Overlay
          if (_showGameOver)
            GameOverOverlay(
              score: _game.score,
              highScore: _highScore,
              isNewRecord: _game.isNewRecord,
              onRestart: () {
                _game.restart();
                setState(() {
                  _showGameOver = false;
                });
              },
              onMainMenu: () {
                Navigator.of(context).pop();
              },
            ),

          // 튜토리얼 오버레이
          if (_showTutorial)
            TutorialOverlay(
              onComplete: () {
                setState(() => _showTutorial = false);
              },
            ),
        ],
      ),
    );
  }
}
