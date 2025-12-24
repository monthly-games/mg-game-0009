import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mg_common_game/core/economy/gold_manager.dart';
import 'package:get_it/get_it.dart';

enum SnakeSkin {
  classic(0, '기본', Color(0xFF4CAF50), 0),
  neonBlue(500, '네온 블루', Color(0xFF00FFFF), 1),
  rubyRed(1000, '루비 레드', Color(0xFFFF0055), 2),
  golden(2500, '골드', Color(0xFFFFD700), 3),
  obsidian(1500, '옵시디언', Color(0xFF222222), 4),
  pixel(800, '레트로 픽셀', Color(0xFF00FF00), 5),
  lava(1200, '용암', Color(0xFFFF5722), 6),
  ice(1200, '얼음', Color(0xFFE0F7FA), 7),
  cyber(2000, '사이버펑크', Color(0xFFD500F9), 8),
  ghost(3000, '유령', Color(0xAAFFFFFF), 9);

  final int cost;
  final String name;
  final Color baseColor;
  final int spriteRowIndex;

  const SnakeSkin(this.cost, this.name, this.baseColor, this.spriteRowIndex);
}

enum FoodSkin {
  apple(0, '사과', 0),
  mouse(500, '쥐', 1),
  burger(800, '햄버거', 2),
  diamond(1500, '다이아몬드', 3),
  coin(1000, '코인', 4),
  potion(2000, '물약', 5);

  final int cost;
  final String name;
  final int spriteIndex;

  const FoodSkin(this.cost, this.name, this.spriteIndex);
}

class SkinManager extends ChangeNotifier {
  static const String _snakeSkinKey = 'snake_skin_v1';
  static const String _foodSkinKey = 'food_skin_v1';
  static const String _unlockedSnakesKey = 'unlocked_snakes_v1';
  static const String _unlockedFoodsKey = 'unlocked_foods_v1';

  SnakeSkin _currentSnakeSkin = SnakeSkin.classic;
  FoodSkin _currentFoodSkin = FoodSkin.apple;

  final Set<SnakeSkin> _unlockedSnakes = {SnakeSkin.classic};
  final Set<FoodSkin> _unlockedFoods = {FoodSkin.apple};

  SnakeSkin get currentSnakeSkin => _currentSnakeSkin;
  FoodSkin get currentFoodSkin => _currentFoodSkin;

  bool isSnakeUnlocked(SnakeSkin skin) => _unlockedSnakes.contains(skin);
  bool isFoodUnlocked(FoodSkin skin) => _unlockedFoods.contains(skin);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Selections
    final snakeIndex = prefs.getInt(_snakeSkinKey) ?? 0;
    _currentSnakeSkin =
        SnakeSkin.values[snakeIndex.clamp(0, SnakeSkin.values.length - 1)];

    final foodIndex = prefs.getInt(_foodSkinKey) ?? 0;
    _currentFoodSkin =
        FoodSkin.values[foodIndex.clamp(0, FoodSkin.values.length - 1)];

    // Load Unlocks - Snakes
    final unlockedSnakesList = prefs.getStringList(_unlockedSnakesKey);
    if (unlockedSnakesList != null) {
      _unlockedSnakes.clear();
      for (final indexStr in unlockedSnakesList) {
        final index = int.tryParse(indexStr) ?? 0;
        _unlockedSnakes.add(
          SnakeSkin.values[index.clamp(0, SnakeSkin.values.length - 1)],
        );
      }
    } else {
      _unlockedSnakes.add(SnakeSkin.classic);
    }

    // Load Unlocks - Foods
    final unlockedFoodsList = prefs.getStringList(_unlockedFoodsKey);
    if (unlockedFoodsList != null) {
      _unlockedFoods.clear();
      for (final indexStr in unlockedFoodsList) {
        final index = int.tryParse(indexStr) ?? 0;
        _unlockedFoods.add(
          FoodSkin.values[index.clamp(0, FoodSkin.values.length - 1)],
        );
      }
    } else {
      _unlockedFoods.add(FoodSkin.apple);
    }

    notifyListeners();
  }

  Future<void> setSnakeSkin(SnakeSkin skin) async {
    if (!isSnakeUnlocked(skin)) return;
    _currentSnakeSkin = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_snakeSkinKey, skin.index);
    notifyListeners();
  }

  Future<void> setFoodSkin(FoodSkin skin) async {
    if (!isFoodUnlocked(skin)) return;
    _currentFoodSkin = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_foodSkinKey, skin.index);
    notifyListeners();
  }

  Future<bool> unlockSnakeSkin(SnakeSkin skin) async {
    if (_unlockedSnakes.contains(skin)) return true; // Already unlocked

    final goldManager = GetIt.I<GoldManager>();
    if (goldManager.currentGold >= skin.cost) {
      if (goldManager.trySpendGold(skin.cost)) {
        _unlockedSnakes.add(skin);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          _unlockedSnakesKey,
          _unlockedSnakes.map((e) => e.index.toString()).toList(),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> unlockFoodSkin(FoodSkin skin) async {
    if (_unlockedFoods.contains(skin)) return true;

    final goldManager = GetIt.I<GoldManager>();
    if (goldManager.currentGold >= skin.cost) {
      if (goldManager.trySpendGold(skin.cost)) {
        _unlockedFoods.add(skin);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          _unlockedFoodsKey,
          _unlockedFoods.map((e) => e.index.toString()).toList(),
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
