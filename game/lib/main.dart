import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter/material.dart';
import 'ui/main_menu.dart';

import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'game/skin_manager.dart';
import 'screens/daily_quest_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/collection_screen.dart';
import 'game/tutorial_config.dart';
import 'game/balancing_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setupDI();
  // ── Tutorial & Balancing ──────────────────────────────────
  if (!GetIt.I.isRegistered<TutorialManager>()) {
    final tutorialManager = TutorialManager();
    await tutorialManager.initialize();
    tutorialManager.registerTutorial(
      kOnboardingTutorial.id,
      kOnboardingTutorial.steps,
    );
    GetIt.I.registerSingleton<TutorialManager>(tutorialManager);
  }
  if (!GetIt.I.isRegistered<BalancingManager>()) {
    GetIt.I.registerSingleton<BalancingManager>(
      BalancingManager(defaultConfig: kDefaultBalancingConfig),
    );
  }
  // ── Q7 DI Fix: Missing Systems ──────────────────────────
  if (!GetIt.I.isRegistered<BattlePassManager>()) {
    GetIt.I.registerSingleton<BattlePassManager>(BattlePassManager());
  }
  if (!GetIt.I.isRegistered<GachaManager>()) {
    GetIt.I.registerSingleton<GachaManager>(GachaManager());
  }

  runApp(const SnakeGameApp());
}

Future<void> _setupDI() async {
  // 1. Audio Manager
  if (!GetIt.I.isRegistered<AudioManager>()) {
    final audioManager = AudioManager();
    GetIt.I.registerSingleton<AudioManager>(audioManager);
    await audioManager.initialize();
  }

  // 2. Progression Manager
  if (!GetIt.I.isRegistered<ProgressionManager>()) {
    final progressionManager = ProgressionManager();
    GetIt.I.registerSingleton(progressionManager);

    progressionManager.onLevelUp = (newLevel) {
      if (GetIt.I.isRegistered<SettingsManager>()) {
        GetIt.I<SettingsManager>().triggerVibration(
          intensity: VibrationIntensity.heavy,
        );
      }
    };
  }

  // 3. Upgrade Manager
  if (!GetIt.I.isRegistered<UpgradeManager>()) {
    final upgradeManager = UpgradeManager();
    upgradeManager.registerUpgrade(
      Upgrade(
        id: 'snake_speed',
        name: 'Speed Control',
        description: 'Reduces starting speed by 5%',
        maxLevel: 10,
        baseCost: 200,
        costMultiplier: 1.5,
        valuePerLevel: 0.05,
      ),
    );

    upgradeManager.registerUpgrade(
      Upgrade(
        id: 'score_multiplier',
        name: 'Score Boost',
        description: 'Increases score by 10%',
        maxLevel: 10,
        baseCost: 250,
        costMultiplier: 1.5,
        valuePerLevel: 0.1,
      ),
    );

    upgradeManager.registerUpgrade(
      Upgrade(
        id: 'bonus_food',
        name: 'Bonus Food',
        description: 'Chance for bonus food',
        maxLevel: 5,
        baseCost: 400,
        costMultiplier: 1.8,
        valuePerLevel: 0.05,
      ),
    );
    GetIt.I.registerSingleton(upgradeManager);
  }

  // 4. Achievement Manager
  if (!GetIt.I.isRegistered<AchievementManager>()) {
    final achievementManager = AchievementManager();
    achievementManager.registerAchievement(
      Achievement(
        id: 'first_10',
        title: 'Hungry Snake',
        description: 'Eat 10 food',
        iconAsset: 'assets/images/icon_food.png',
      ),
    );
    achievementManager.registerAchievement(
      Achievement(
        id: 'snake_50',
        title: 'Growing Big',
        description: 'Score 50 points',
        iconAsset: 'assets/images/icon_star.png',
      ),
    );
    achievementManager.registerAchievement(
      Achievement(
        id: 'snake_100',
        title: 'Giant Snake',
        description: 'Score 100 points',
        iconAsset: 'assets/images/icon_crown.png',
      ),
    );
    achievementManager.registerAchievement(
      Achievement(
        id: 'hard_mode_30',
        title: 'Obstacle Master',
        description: 'Score 30 in Hard Mode',
        iconAsset: 'assets/images/icon_flash.png',
      ),
    );
    achievementManager.registerAchievement(
      Achievement(
        id: 'time_attack_50',
        title: 'Speed Eater',
        description: 'Score 50 in Time Attack',
        iconAsset: 'assets/images/icon_timer.png',
      ),
    );

    achievementManager.onAchievementUnlocked = (achievement) {
      if (GetIt.I.isRegistered<SettingsManager>()) {
        GetIt.I<SettingsManager>().triggerVibration(
          intensity: VibrationIntensity.heavy,
        );
      }
    };

    GetIt.I.registerSingleton(achievementManager);
  }

  // 5. Prestige Manager
  if (!GetIt.I.isRegistered<PrestigeManager>()) {
    final prestigeManager = PrestigeManager();

    prestigeManager.registerPrestigeUpgrade(
      PrestigeUpgrade(
        id: 'prestige_xp_boost',
        name: 'XP Accelerator',
        description: '+20% XP gain per level',
        maxLevel: 10,
        costPerLevel: 1,
        bonusPerLevel: 0.2,
      ),
    );

    prestigeManager.registerPrestigeUpgrade(
      PrestigeUpgrade(
        id: 'prestige_gold_boost',
        name: 'Golden Scales',
        description: '+15% gold income per level',
        maxLevel: 10,
        costPerLevel: 1,
        bonusPerLevel: 0.15,
      ),
    );

    prestigeManager.registerPrestigeUpgrade(
      PrestigeUpgrade(
        id: 'prestige_snake_slow',
        name: 'Master Control',
        description: '+5% slower speed per level',
        maxLevel: 15,
        costPerLevel: 2,
        bonusPerLevel: 0.05,
      ),
    );

    GetIt.I.registerSingleton(prestigeManager);

    await prestigeManager.loadPrestigeData();
    GetIt.I<ProgressionManager>().setPrestigeManager(prestigeManager);
  }

  // 6. Daily Quest Manager
  if (!GetIt.I.isRegistered<DailyQuestManager>()) {
    final questManager = DailyQuestManager();

    questManager.registerQuest(
      DailyQuest(
        id: 'snake_play_5',
        title: 'Daily Slitherer',
        description: 'Play 5 games',
        targetValue: 5,
        goldReward: 100,
        xpReward: 50,
      ),
    );

    questManager.registerQuest(
      DailyQuest(
        id: 'snake_food_50',
        title: 'Food Collector',
        description: 'Eat 50 food total',
        targetValue: 50,
        goldReward: 130,
        xpReward: 65,
      ),
    );

    questManager.registerQuest(
      DailyQuest(
        id: 'snake_normal_30',
        title: 'Normal Champion',
        description: 'Score 30 in Normal mode',
        targetValue: 30,
        goldReward: 150,
        xpReward: 75,
      ),
    );

    questManager.registerQuest(
      DailyQuest(
        id: 'snake_hard_20',
        title: 'Obstacle Dodger',
        description: 'Score 20 in Hard mode',
        targetValue: 20,
        goldReward: 200,
        xpReward: 100,
      ),
    );

    questManager.registerQuest(
      DailyQuest(
        id: 'snake_time_30',
        title: 'Time Attack Pro',
        description: 'Score 30 in Time Attack',
        targetValue: 30,
        goldReward: 180,
        xpReward: 90,
      ),
    );

    GetIt.I.registerSingleton(questManager);

    questManager.loadQuestData();
    questManager.checkAndResetIfNeeded();
  }

  // 7. Weekly Challenge Manager
  if (!GetIt.I.isRegistered<WeeklyChallengeManager>()) {
    final challengeManager = WeeklyChallengeManager();

    challengeManager.onChallengeCompleted = (challenge) {
      if (GetIt.I.isRegistered<SettingsManager>()) {
        GetIt.I<SettingsManager>().triggerVibration(
          intensity: VibrationIntensity.heavy,
        );
      }
    };

    challengeManager.registerChallenge(
      WeeklyChallenge(
        id: 'weekly_snake_play_30',
        title: 'Dedicated Slitherer',
        description: 'Play 30 games',
        targetValue: 30,
        goldReward: 500,
        xpReward: 250,
        tier: ChallengeTier.bronze,
      ),
    );

    challengeManager.registerChallenge(
      WeeklyChallenge(
        id: 'weekly_snake_food_500',
        title: 'Food Hoarder',
        description: 'Eat 500 food total',
        targetValue: 500,
        goldReward: 750,
        xpReward: 400,
        tier: ChallengeTier.silver,
      ),
    );

    challengeManager.registerChallenge(
      WeeklyChallenge(
        id: 'weekly_snake_normal_100',
        title: 'Normal Master',
        description: 'Score 100 in Normal mode',
        targetValue: 100,
        goldReward: 1000,
        xpReward: 500,
        tier: ChallengeTier.silver,
      ),
    );

    challengeManager.registerChallenge(
      WeeklyChallenge(
        id: 'weekly_snake_hard_50',
        title: 'Hard Mode Champion',
        description: 'Score 50 in Hard mode',
        targetValue: 50,
        goldReward: 1500,
        xpReward: 800,
        prestigePointReward: 1,
        tier: ChallengeTier.gold,
      ),
    );

    challengeManager.registerChallenge(
      WeeklyChallenge(
        id: 'weekly_snake_time_80',
        title: 'Time Attack Legend',
        description: 'Score 80 in Time Attack',
        targetValue: 80,
        goldReward: 1200,
        xpReward: 600,
        tier: ChallengeTier.gold,
      ),
    );

    challengeManager.registerChallenge(
      WeeklyChallenge(
        id: 'weekly_snake_legend',
        title: 'Snake Legend',
        description: 'Score 150 in any mode',
        targetValue: 150,
        goldReward: 2000,
        xpReward: 1000,
        prestigePointReward: 2,
        tier: ChallengeTier.platinum,
      ),
    );

    GetIt.I.registerSingleton(challengeManager);

    await challengeManager.loadChallengeData();
    await challengeManager.checkAndResetIfNeeded();
  }

  // 8. Gold Manager
  if (!GetIt.I.isRegistered<GoldManager>()) {
    GetIt.I.registerSingleton(GoldManager());
  }

  // 8.5 Skin Manager
  if (!GetIt.I.isRegistered<SkinManager>()) {
    final skinManager = SkinManager();
    GetIt.I.registerSingleton(skinManager);
    await skinManager.load();
  }

  // 9. Settings Manager
  if (!GetIt.I.isRegistered<SettingsManager>()) {
    final settingsManager = SettingsManager();
    GetIt.I.registerSingleton(settingsManager);

    if (GetIt.I.isRegistered<AudioManager>()) {
      settingsManager.setAudioManager(GetIt.I<AudioManager>());
    }

    await settingsManager.loadSettings();
  }

  // 10. Statistics Manager
  if (!GetIt.I.isRegistered<StatisticsManager>()) {
    final statisticsManager = StatisticsManager();
    GetIt.I.registerSingleton(statisticsManager);
  // Collection 시스템
  if (!GetIt.I.isRegistered<CollectionManager>()) {
    GetIt.I.registerSingleton(CollectionManager());
  // ── Retention Systems for DailyHub ────────────────────────
  if (!GetIt.I.isRegistered<LoginRewardsManager>()) {
    GetIt.I.registerSingleton(LoginRewardsManager());
  }
  if (!GetIt.I.isRegistered<StreakManager>()) {
    GetIt.I.registerSingleton(StreakManager());
  }
  if (!GetIt.I.isRegistered<DailyChallengeManager>()) {
    GetIt.I.registerSingleton(DailyChallengeManager());
}
  // ── P3 Engine Systems ─────────────────────────────────────
  if (!GetIt.I.isRegistered<GuildWarManager>()) {
    GetIt.I.registerSingleton(GuildWarManager());
  }
  if (!GetIt.I.isRegistered<TournamentManager>()) {
    GetIt.I.registerSingleton(TournamentManager());
  }
  if (!GetIt.I.isRegistered<SeasonalContentManager>()) {
    GetIt.I.registerSingleton(SeasonalContentManager());
  }
    _registerCollections();
  }

    await statisticsManager.loadStats();
    statisticsManager.startSession();
  }

  // 11. Save Manager
  await SaveManagerHelper.setupSaveManager(
    autoSaveEnabled: true,
    autoSaveIntervalSeconds: 30,
  );

  await SaveManagerHelper.legacyLoadAll();
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MGColors.success,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/daily-quest': (_) => const DailyQuestScreen(),
        '/achievements': (_) => const AchievementScreen(),
        '/daily-hub': (context) => DailyHubScreen(
          questManager: GetIt.I<DailyQuestManager>(),
          loginRewardsManager: GetIt.I<LoginRewardsManager>(),
          streakManager: GetIt.I<StreakManager>(),
          challengeManager: GetIt.I<DailyChallengeManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
        ),
      
        '/collection': (context) => CollectionScreen(
          collectionManager: GetIt.I<CollectionManager>(),
        ),
        '/guild-war': (context) => GuildWarScreen(
          guildWarManager: GetIt.I<GuildWarManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/tournament': (context) => TournamentScreen(
          tournamentManager: GetIt.I<TournamentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
        '/seasonal-event': (context) => SeasonalEventScreen(
          seasonalContentManager: GetIt.I<SeasonalContentManager>(),
          accentColor: MGColors.primaryAction,
          onClose: () => Navigator.pop(context),
          ),
},
      home: const MainMenu(),
    );
  }
}

void _registerCollections() {
  final collection = GetIt.I<CollectionManager>();

  // Characters 컬렉션
  collection.registerCollection(Collection(
    id: 'characters',
    name: '캐릭터',
    description: '모든 캐릭터를 수집하세요',
    items: [
      const CollectionItem(
        id: 'char_warrior',
        name: '전사',
        description: '강인한 근접 전투 캐릭터',
        rarity: CollectionRarity.common,
      ),
      const CollectionItem(
        id: 'char_mage',
        name: '마법사',
        description: '강력한 마법 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_archer',
        name: '궁수',
        description: '원거리 정밀 공격 캐릭터',
        rarity: CollectionRarity.rare,
      ),
      const CollectionItem(
        id: 'char_assassin',
        name: '암살자',
        description: '치명적인 은신 공격 캐릭터',
        rarity: CollectionRarity.epic,
      ),
      const CollectionItem(
        id: 'char_healer',
        name: '힐러',
        description: '팀을 치유하는 지원 캐릭터',
        rarity: CollectionRarity.legendary,
      ),
    ],
    completionReward: const CollectionReward(type: RewardType.gold, amount: 10000),
    milestoneRewards: {
      25: const CollectionReward(type: RewardType.gold, amount: 1000),
      50: const CollectionReward(type: RewardType.gold, amount: 3000),
      75: const CollectionReward(type: RewardType.gold, amount: 5000),
    },
  ));

  // 아이템 해제 콜백 (햅틱 피드백)
  collection.onItemUnlocked = (collectionId, itemId) {
    // SettingsManager가 등록되어 있으면 햅틱 피드백
    debugPrint('Collection item unlocked: $collectionId / $itemId');
  };
}
