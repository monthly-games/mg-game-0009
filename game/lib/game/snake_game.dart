import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'effects/particle_effects.dart';
import 'effects/score_popup.dart';
import 'effects/screen_shake.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import '../utils/high_score_manager.dart';
import 'skin_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

enum Direction { up, down, left, right }

enum SnakeGameMode { normal, hard, timeAttack, battle }

class SnakeGame extends FlameGame with KeyboardEvents, DragCallbacks {
  final SnakeGameMode mode;
  final VoidCallback? onGameOver;

  SnakeGame({this.mode = SnakeGameMode.normal, this.onGameOver});

  AudioManager get _audioManager => GetIt.I<AudioManager>();
  SkinManager get _skinManager => GetIt.I<SkinManager>();
  // Swipe detection variables
  Vector2? _dragStart;
  static const double swipeThreshold = 50.0; // Minimum swipe distance
  static const int gridSize = 20; // Grid size

  // Mode-based settings
  double get moveInterval {
    // Speed boost effect overrides
    if (activeEffect == FoodType.speedBoost) {
      return baseMoveInterval * 0.6;
    }

    switch (mode) {
      case SnakeGameMode.hard:
        return 0.08;
      case SnakeGameMode.timeAttack:
        return 0.12;
      case SnakeGameMode.battle:
        return 0.13;
      case SnakeGameMode.normal:
        return baseMoveInterval;
    }
  }

  List<Vector2> snake = []; // Snake body (grid coordinates)
  Vector2 food = Vector2.zero(); // Food position
  Direction currentDirection = Direction.right;
  Direction nextDirection = Direction.right;

  double moveTimer = 0;
  int score = 0;
  bool gameOver = false;
  bool gameStarted = false;
  bool isNewRecord = false;

  // Time Attack logic
  double remainingTime = 60.0;

  // Special food system
  FoodType currentFoodType = FoodType.normal;
  FoodType? activeEffect;
  Timer? effectTimer;
  double baseMoveInterval = 0.15;
  bool get isGhostMode => activeEffect == FoodType.ghostMode;
  bool get isInvincible => activeEffect == FoodType.invincibility;
  bool get isDoublePoints => activeEffect == FoodType.doublePoints;

  // Battle mode
  List<Vector2> opponentSnake = [];
  Direction opponentDirection = Direction.right;
  Vector2 opponentFood = Vector2.zero();
  int opponentScore = 0;
  List<Vector2> obstacles = [];
  Timer? opponentMoveTimer;
  static const double opponentMoveInterval = 0.2;

  @override
  bool paused = false;

  late double cellSize; // 셀 크기 (픽셀)

  SpriteSheet? _snakeSpriteSheet;
  SpriteSheet? _foodSpriteSheet;
  ui.Image? _snakeImage;
  ui.Image? _foodImage;

  @override
  Color backgroundColor() => const Color(0xFF1a1a1a); // 어두운 배경

  @override
  Future<void> onLoad() async {
    // 화면 크기에 맞춰 셀 크기 계산
    final smallerDimension = size.x < size.y ? size.x : size.y;
    cellSize = smallerDimension / gridSize;

    // Load Assets
    try {
      _snakeImage = await images.load('snake_sheet.png');
      _foodImage = await images.load('food_sheet.png');

      _snakeSpriteSheet = SpriteSheet(
        image: _snakeImage!,
        srcSize: Vector2(32, 32),
      );

      _foodSpriteSheet = SpriteSheet(
        image: _foodImage!,
        srcSize: Vector2(32, 32),
      );
    } catch (e) {
      debugPrint('Failed to load sprites: $e');
    }

    _initializeGame();
  }

  void _initializeGame() {
    // Initial snake position (center, 3 cells)
    snake = [
      Vector2(gridSize / 2, gridSize / 2),
      Vector2(gridSize / 2 - 1, gridSize / 2),
      Vector2(gridSize / 2 - 2, gridSize / 2),
    ];

    currentDirection = Direction.right;
    nextDirection = Direction.right;
    score = 0;
    remainingTime = 60.0;
    gameOver = false;
    gameStarted = false;
    isNewRecord = false;
    moveTimer = 0;

    // Reset special food effects
    effectTimer?.cancel();
    activeEffect = null;
    currentFoodType = FoodType.normal;
    baseMoveInterval = mode == SnakeGameMode.hard ? 0.08 :
                      mode == SnakeGameMode.timeAttack ? 0.12 : 0.15;

    // Battle mode initialization
    if (mode == SnakeGameMode.battle) {
      _initializeBattleMode();
    }

    _spawnFood();
  }

  void _initializeBattleMode() {
    // Opponent snake starts from opposite side
    opponentSnake = [
      Vector2(gridSize / 2 + 5, gridSize / 2),
      Vector2(gridSize / 2 + 6, gridSize / 2),
      Vector2(gridSize / 2 + 7, gridSize / 2),
    ];
    opponentDirection = Direction.left;
    opponentScore = 0;

    // Spawn obstacles (5 random obstacles)
    obstacles.clear();
    for (int i = 0; i < 5; i++) {
      bool validPosition = false;
      Vector2 obsPos;
      while (!validPosition) {
        obsPos = Vector2(
          (Vector2.random().x * gridSize).floor().toDouble(),
          (Vector2.random().y * gridSize).floor().toDouble(),
        );

        // Check not overlapping with either snake
        validPosition = !snake.any((seg) => seg == obsPos) &&
                       !opponentSnake.any((seg) => seg == obsPos) &&
                       !obstacles.any((obs) => obs == obsPos);
      }
      obstacles.add(obsPos);
    }

    _spawnOpponentFood();
  }

  void _spawnOpponentFood() {
    bool validPosition = false;
    while (!validPosition) {
      opponentFood = Vector2(
        (Vector2.random().x * gridSize).floor().toDouble(),
        (Vector2.random().y * gridSize).floor().toDouble(),
      );

      validPosition = !snake.any((seg) => seg == opponentFood) &&
                     !opponentSnake.any((seg) => seg == opponentFood) &&
                     !obstacles.any((obs) => obs == opponentFood);
    }
  }

  void _activateSpecialEffect(FoodType type) {
    if (!type.isSpecial) return;

    // Cancel previous effect timer
    effectTimer?.cancel();

    activeEffect = type;
    _audioManager.playSfx('powerup.wav');

    // Schedule effect end
    if (type.duration != null) {
      effectTimer = Timer(type.duration!, () {
        activeEffect = null;
        effectTimer = null;
      });
    }

    // Add visual effect
    final head = snake.first;
    final boardSize = gridSize * cellSize;
    final offsetX = (size.x - boardSize) / 2;
    final offsetY = (size.y - boardSize) / 2;
    final headPixelPos = Vector2(
      offsetX + head.x * cellSize + cellSize / 2,
      offsetY + head.y * cellSize + cellSize / 2,
    );

    add(PowerUpParticleEffect(position: headPixelPos, type: type));
  }

  void _spawnFood() {
    // Spawn food at random position not occupied by snake
    bool validPosition = false;
    while (!validPosition) {
      food = Vector2(
        (Vector2.random().x * gridSize).floor().toDouble(),
        (Vector2.random().y * gridSize).floor().toDouble(),
      );

      // Check if food doesn't overlap with snake
      validPosition = !snake.any((segment) => segment == food);

      // Battle mode: check obstacles
      if (mode == SnakeGameMode.battle) {
        validPosition = validPosition && !obstacles.any((obs) => obs == food);
      }
    }

    // Determine food type (10% chance for special food in normal modes)
    if (mode != SnakeGameMode.battle) {
      final rand = Vector2.random().x;
      if (rand < 0.03) {
        currentFoodType = FoodType.speedBoost;
      } else if (rand < 0.06) {
        currentFoodType = FoodType.ghostMode;
      } else if (rand < 0.08) {
        currentFoodType = FoodType.doublePoints;
      } else if (rand < 0.10) {
        currentFoodType = FoodType.invincibility;
      } else {
        currentFoodType = FoodType.normal;
      }
    } else {
      currentFoodType = FoodType.normal;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameStarted || gameOver || paused) return;

    // Time Attack Timer
    if (mode == SnakeGameMode.timeAttack) {
      remainingTime -= dt;
      if (remainingTime <= 0) {
        remainingTime = 0;
        _endGame();
        return; // Stop update if game ended
      }
    }

    moveTimer += dt;
    if (moveTimer >= moveInterval) {
      moveTimer = 0;
      _moveSnake();
    }
  }

  void _moveSnake() {
    // Update direction (to next direction)
    currentDirection = nextDirection;

    // Calculate new head position
    final head = snake.first;
    Vector2 newHead;

    switch (currentDirection) {
      case Direction.up:
        newHead = Vector2(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Vector2(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Vector2(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Vector2(head.x + 1, head.y);
        break;
    }

    // Wall collision check (ghost mode can pass through walls)
    if (newHead.x < 0 ||
        newHead.x >= gridSize ||
        newHead.y < 0 ||
        newHead.y >= gridSize) {
      if (isGhostMode) {
        // Wrap around
        if (newHead.x < 0) newHead = Vector2(gridSize - 1, newHead.y);
        if (newHead.x >= gridSize) newHead = Vector2(0, newHead.y);
        if (newHead.y < 0) newHead = Vector2(newHead.x, gridSize - 1);
        if (newHead.y >= gridSize) newHead = Vector2(newHead.x, 0);
      } else {
        _endGame();
        return;
      }
    }

    // Self collision check (ghost mode and invincibility can pass through self)
    if (snake.any((segment) => segment == newHead)) {
      if (!isGhostMode && !isInvincible) {
        _endGame();
        return;
      }
    }

    // Battle mode: collision with opponent
    if (mode == SnakeGameMode.battle) {
      // Head-to-head collision = both lose
      if (opponentSnake.first == newHead) {
        _endBattleMode(draw: true);
        return;
      }

      // Head hits opponent body = opponent wins
      if (opponentSnake.any((seg) => seg == newHead)) {
        if (!isInvincible) {
          _endBattleMode(playerWon: false);
          return;
        }
      }

      // Collision with obstacles
      if (obstacles.any((obs) => obs == newHead)) {
        if (!isInvincible) {
          _endBattleMode(playerWon: false);
          return;
        }
      }
    }

    // Add new head
    snake.insert(0, newHead);

    // Check if food eaten
    if (newHead == food) {
      // Calculate points (consider double points effect)
      final points = currentFoodType.points * (isDoublePoints ? 2 : 1);
      score += points;

      _audioManager.playSfx('eat.wav');

      // Add visual effects for eating food
      final boardSize = gridSize * cellSize;
      final offsetX = (size.x - boardSize) / 2;
      final offsetY = (size.y - boardSize) / 2;
      final foodPixelPos = Vector2(
        offsetX + food.x * cellSize + cellSize / 2,
        offsetY + food.y * cellSize + cellSize / 2,
      );

      add(FoodParticleEffect(position: foodPixelPos));
      add(ScorePopup(position: foodPixelPos, points: points));

      // Activate special effect if applicable
      if (currentFoodType.isSpecial) {
        _activateSpecialEffect(currentFoodType);
      }

      _spawnFood();
      // Don't remove tail (snake grows)
    } else {
      // Remove tail (maintain length)
      snake.removeLast();
    }

    // Battle mode: opponent AI
    if (mode == SnakeGameMode.battle) {
      _updateOpponent();
    }
  }

  Future<void> _endGame() async {
    if (gameOver) return;
    gameOver = true;

    // Only play collision sound if not time attack time up (or play specific sound)
    if (mode != SnakeGameMode.timeAttack || remainingTime > 0) {
      _audioManager.playSfx('collision.wav');
    }

    // Add game over effects
    final head = snake.first;
    final boardSize = gridSize * cellSize;
    final offsetX = (size.x - boardSize) / 2;
    final offsetY = (size.y - boardSize) / 2;
    final headPixelPos = Vector2(
      offsetX + head.x * cellSize + cellSize / 2,
      offsetY + head.y * cellSize + cellSize / 2,
    );

    add(GameOverParticleEffect(position: headPixelPos));
    add(ScreenShakeEffect(game: this, intensity: 15.0, duration: 0.4));

    // Save High Score
    final newRecord = await HighScoreManager.saveHighScore(mode.name, score);
    if (newRecord) {
      isNewRecord = true;
      _audioManager.playSfx('score.wav');
    }

    onGameOver?.call();
  }

  void _updateOpponent() {
    // Simple AI: move towards food while avoiding collisions
    final head = opponentSnake.first;
    Vector2 targetFood = opponentFood;

    // Occasionally target player's food for competitive play
    if (Vector2.random().x < 0.3) {
      targetFood = food;
    }

    // Determine best direction (simplified pathfinding)
    Direction bestDirection = opponentDirection;
    double bestDistance = double.infinity;

    for (final dir in Direction.values) {
      // Prevent 180 degree turns
      if ((dir == Direction.up && opponentDirection == Direction.down) ||
          (dir == Direction.down && opponentDirection == Direction.up) ||
          (dir == Direction.left && opponentDirection == Direction.right) ||
          (dir == Direction.right && opponentDirection == Direction.left)) {
        continue;
      }

      Vector2 newHead;
      switch (dir) {
        case Direction.up:
          newHead = Vector2(head.x, head.y - 1);
          break;
        case Direction.down:
          newHead = Vector2(head.x, head.y + 1);
          break;
        case Direction.left:
          newHead = Vector2(head.x - 1, head.y);
          break;
        case Direction.right:
          newHead = Vector2(head.x + 1, head.y);
          break;
      }

      // Check if valid move
      bool valid = newHead.x >= 0 && newHead.x < gridSize &&
                   newHead.y >= 0 && newHead.y < gridSize;
      valid = valid && !opponentSnake.any((seg) => seg == newHead);
      valid = valid && !obstacles.any((obs) => obs == newHead);

      if (valid) {
        final distance = (newHead - targetFood).length;
        if (distance < bestDistance) {
          bestDistance = distance;
          bestDirection = dir;
        }
      }
    }

    opponentDirection = bestDirection;

    // Move opponent
    Vector2 newOpponentHead;
    switch (opponentDirection) {
      case Direction.up:
        newOpponentHead = Vector2(head.x, head.y - 1);
        break;
      case Direction.down:
        newOpponentHead = Vector2(head.x, head.y + 1);
        break;
      case Direction.left:
        newOpponentHead = Vector2(head.x - 1, head.y);
        break;
      case Direction.right:
        newOpponentHead = Vector2(head.x + 1, head.y);
        break;
    }

    opponentSnake.insert(0, newOpponentHead);

    // Check if opponent ate food
    if (newOpponentHead == opponentFood) {
      opponentScore++;
      _spawnOpponentFood();
    } else if (newOpponentHead == food) {
      opponentScore += 2; // Bonus for stealing player's food
      _spawnFood();
    } else {
      opponentSnake.removeLast();
    }

    // Check opponent collision with player
    if (newOpponentHead == snake.first) {
      _endBattleMode(playerWon: true);
      return;
    }

    if (snake.any((seg) => seg == newOpponentHead)) {
      // Opponent hit player body - player wins
      _endBattleMode(playerWon: true);
      return;
    }

    // Win condition: first to 15 points
    if (score >= 15) {
      _endBattleMode(playerWon: true);
      return;
    }
    if (opponentScore >= 15) {
      _endBattleMode(playerWon: false);
      return;
    }
  }

  void _endBattleMode({bool? playerWon, bool? draw}) {
    if (gameOver) return;
    gameOver = true;

    _audioManager.playSfx('collision.wav');

    // Store result for overlay to display
    if (draw == true) {
      score = -1; // Special code for draw
    } else if (playerWon == false) {
      score = -2; // Special code for loss
    }

    onGameOver?.call();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Cleanup timers when app goes to background
      effectTimer?.cancel();
    }
  }

  void restart() {
    _initializeGame();
  }

  void togglePause() {
    paused = !paused;
  }

  void resume() {
    paused = false;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (paused) return KeyEventResult.handled;

    if (gameOver) {
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        restart();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (!gameStarted) {
      gameStarted = true;
      return KeyEventResult.handled;
    }

    // Direction change (180 degree turn not allowed)
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      if (currentDirection != Direction.down) {
        nextDirection = Direction.up;
        _audioManager.playSfx('turn.wav');
      }
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      if (currentDirection != Direction.up) {
        nextDirection = Direction.down;
        _audioManager.playSfx('turn.wav');
      }
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      if (currentDirection != Direction.right) {
        nextDirection = Direction.left;
        _audioManager.playSfx('turn.wav');
      }
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      if (currentDirection != Direction.left) {
        nextDirection = Direction.right;
        _audioManager.playSfx('turn.wav');
      }
    }

    return KeyEventResult.handled;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (paused) return;
    _dragStart = event.localPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (paused || _dragStart == null) return;

    // Use velocity to determine direction
    final velocity = event.velocity;

    // Ignore if velocity is too small
    if (velocity.length < 100) {
      _dragStart = null;
      return;
    }

    // Determine based on larger horizontal/vertical component
    if (velocity.x.abs() > velocity.y.abs()) {
      // Horizontal swipe
      if (velocity.x > 0 && currentDirection != Direction.left) {
        nextDirection = Direction.right;
        _audioManager.playSfx('turn.wav');
      } else if (velocity.x < 0 && currentDirection != Direction.right) {
        nextDirection = Direction.left;
        _audioManager.playSfx('turn.wav');
      }
    } else {
      // Vertical swipe
      if (velocity.y > 0 && currentDirection != Direction.up) {
        nextDirection = Direction.down;
        _audioManager.playSfx('turn.wav');
      } else if (velocity.y < 0 && currentDirection != Direction.down) {
        nextDirection = Direction.up;
        _audioManager.playSfx('turn.wav');
      }
    }

    // Start game (touch to start)
    if (!gameStarted && !gameOver) {
      gameStarted = true;
    }

    _dragStart = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Offset for game board center alignment
    final boardSize = gridSize * cellSize;
    final offsetX = (size.x - boardSize) / 2;
    final offsetY = (size.y - boardSize) / 2;

    // Draw grid (light lines)
    _drawGrid(canvas, offsetX, offsetY);

    // Draw food
    _drawFood(canvas, offsetX, offsetY);

    // Draw snake
    _drawSnake(canvas, offsetX, offsetY);

    // Battle mode: draw opponent and obstacles
    if (mode == SnakeGameMode.battle) {
      _drawBattleElements(canvas, offsetX, offsetY);
    }

    // Draw UI text
    _drawUI(canvas);
  }

  void _drawGrid(Canvas canvas, double offsetX, double offsetY) {
    final paint = Paint()
      ..color = MGColors.textDisabled
      ..strokeWidth = 1;

    for (int i = 0; i <= gridSize; i++) {
      // 세로선
      canvas.drawLine(
        Offset(offsetX + i * cellSize, offsetY),
        Offset(offsetX + i * cellSize, offsetY + gridSize * cellSize),
        paint,
      );
      // 가로선
      canvas.drawLine(
        Offset(offsetX, offsetY + i * cellSize),
        Offset(offsetX + gridSize * cellSize, offsetY + i * cellSize),
        paint,
      );
    }
  }

  void _drawFood(Canvas canvas, double offsetX, double offsetY) {
    // Determine color based on food type
    Color foodColor;
    if (currentFoodType.isSpecial) {
      foodColor = currentFoodType.color;
    } else {
      switch (_skinManager.currentFoodSkin) {
        case FoodSkin.apple:
          foodColor = MGColors.error;
          break;
        case FoodSkin.mouse:
          foodColor = MGColors.common;
          break;
        case FoodSkin.burger:
          foodColor = MGColors.warning;
          break;
        case FoodSkin.diamond:
          foodColor = MGColors.energy;
          break;
        case FoodSkin.coin:
          foodColor = MGColors.gold;
          break;
        case FoodSkin.potion:
          foodColor = MGColors.gem;
          break;
      }
    }

    if (_foodSpriteSheet != null && !currentFoodType.isSpecial) {
      final spriteIndex = _skinManager.currentFoodSkin.spriteIndex;
      final sprite = _foodSpriteSheet!.getSprite(0, spriteIndex);

      sprite.render(
        canvas,
        position: Vector2(
          offsetX + food.x * cellSize,
          offsetY + food.y * cellSize,
        ),
        size: Vector2(cellSize, cellSize),
      );
      return;
    }

    // Fallback logic and special food rendering
    final paint = Paint()..color = foodColor;

    final rect = Rect.fromLTWH(
      offsetX + food.x * cellSize + 2,
      offsetY + food.y * cellSize + 2,
      cellSize - 4,
      cellSize - 4,
    );

    // Different shapes for special food
    if (currentFoodType == FoodType.invincibility) {
      // Star shape for invincibility
      _drawStar(canvas, rect.center, cellSize / 2 - 2, foodColor);
    } else if (currentFoodType.isSpecial) {
      // Diamond shape for other special food
      final path = Path();
      final center = rect.center;
      final size = cellSize / 2 - 2;
      path.moveTo(center.dx, center.dy - size);
      path.lineTo(center.dx + size, center.dy);
      path.lineTo(center.dx, center.dy + size);
      path.lineTo(center.dx - size, center.dy);
      path.close();
      canvas.drawPath(path, paint);
    } else {
      canvas.drawOval(rect, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()..color = color;
    final path = Path();

    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * 3.14159) / 5 - 3.14159 / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawBattleElements(Canvas canvas, double offsetX, double offsetY) {
    // Draw opponent snake
    final opponentPaint = Paint()
      ..color = MGColors.error
      ..style = PaintingStyle.fill;

    for (int i = 0; i < opponentSnake.length; i++) {
      final segment = opponentSnake[i];
      final isHead = i == 0;

      opponentPaint.color = isHead
          ? MGColors.error
          : MGColors.error.withValues(alpha: 0.6);

      final rect = Rect.fromLTWH(
        offsetX + segment.x * cellSize + 1,
        offsetY + segment.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      canvas.drawRect(rect, opponentPaint);

      // Mark opponent head
      if (isHead) {
        final eyePaint = Paint()..color = MGColors.textHighEmphasis;
        canvas.drawCircle(
          Offset(
            offsetX + segment.x * cellSize + cellSize / 3,
            offsetY + segment.y * cellSize + cellSize / 3,
          ),
          cellSize / 10,
          eyePaint,
        );
        canvas.drawCircle(
          Offset(
            offsetX + segment.x * cellSize + 2 * cellSize / 3,
            offsetY + segment.y * cellSize + cellSize / 3,
          ),
          cellSize / 10,
          eyePaint,
        );
      }
    }

    // Draw obstacles
    final obstaclePaint = Paint()
      ..color = MGColors.cardDark
      ..style = PaintingStyle.fill;

    for (final obs in obstacles) {
      final rect = Rect.fromLTWH(
        offsetX + obs.x * cellSize + 1,
        offsetY + obs.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      // Draw X pattern
      canvas.drawRect(rect, obstaclePaint);
      final linePaint = Paint()
        ..color = MGColors.textDisabled
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(rect.left, rect.top),
        Offset(rect.right, rect.bottom),
        linePaint,
      );
      canvas.drawLine(
        Offset(rect.right, rect.top),
        Offset(rect.left, rect.bottom),
        linePaint,
      );
    }

    // Draw opponent food
    final oppFoodPaint = Paint()..color = MGColors.warning;
    final oppFoodRect = Rect.fromLTWH(
      offsetX + opponentFood.x * cellSize + 4,
      offsetY + opponentFood.y * cellSize + 4,
      cellSize - 8,
      cellSize - 8,
    );
    canvas.drawOval(oppFoodRect, oppFoodPaint);
  }

  void _drawSnake(Canvas canvas, double offsetX, double offsetY) {
    if (_snakeSpriteSheet == null) {
      // Fallback to Rects
      _drawSnakeRects(canvas, offsetX, offsetY);
      return;
    }

    final spriteRow = _skinManager.currentSnakeSkin.spriteRowIndex;

    for (int i = 0; i < snake.length; i++) {
      final segment = snake[i];
      final isHead = i == 0;
      final isTail = i == snake.length - 1;

      // Determine Sprite Column and Rotation
      int colIndex = 1; // Default Body
      double rotation = 0;

      if (isHead) {
        colIndex = 0;
        switch (currentDirection) {
          case Direction.right:
            rotation = 0;
            break;
          case Direction.down:
            rotation = 1.5708;
            break; // 90 deg
          case Direction.left:
            rotation = 3.14159;
            break; // 180 deg
          case Direction.up:
            rotation = 4.71239;
            break; // 270 deg
        }
      } else if (isTail) {
        colIndex = 3;
        final prev = snake[i - 1]; // Segment before tail
        final diff = prev - segment; // Vector from tail to prev

        if (diff.x > 0) {
          rotation =
              0; // Prev is right -> Tail points right (wait, tail should point away?)
        } else if (diff.x < 0) {
          rotation = 3.14159;
        } else if (diff.y > 0) {
          rotation = 1.5708;
        } else if (diff.y < 0) {
          rotation = 4.71239;
        }
      } else {
        // Body
        colIndex = 1;
        final prev = snake[i - 1];
        final next = snake[i + 1];

        if (prev.x == next.x) {
          // Vertical
          rotation = 1.5708;
        } else if (prev.y == next.y) {
          // Horizontal
          rotation = 0;
        } else {
          // Corner - Simplified to Straight for now to avoid logic complexity
          // Or better: just pick straight based on prev-current relation
          final diff = prev - segment;
          if (diff.x != 0) {
            rotation = 0;
          } else {
            rotation = 1.5708;
          }
        }
      }

      final sprite = _snakeSpriteSheet!.getSprite(spriteRow, colIndex);

      final x = offsetX + segment.x * cellSize + cellSize / 2;
      final y = offsetY + segment.y * cellSize + cellSize / 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      // Draw centered
      sprite.render(
        canvas,
        position: Vector2(-cellSize / 2, -cellSize / 2),
        size: Vector2(cellSize, cellSize),
      );
      canvas.restore();
    }
  }

  void _drawSnakeRects(Canvas canvas, double offsetX, double offsetY) {
    for (int i = 0; i < snake.length; i++) {
      final segment = snake[i];
      final isHead = i == 0;

      // Use SkinManager color
      final baseColor = _skinManager.currentSnakeSkin.baseColor;
      final bodyColor = baseColor.withValues(
        alpha: 0.7,
      ); // Lighter/Transparent for body

      final paint = Paint()..color = isHead ? baseColor : bodyColor;

      final rect = Rect.fromLTWH(
        offsetX + segment.x * cellSize + 1,
        offsetY + segment.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      canvas.drawRect(rect, paint);

      // Eyes for head logic ... (omitted for brevity, duplicate of previous logic)
      if (isHead) {
        final eyePaint = Paint()..color = MGColors.textHighEmphasis;
        // ... simple eye dot
        canvas.drawCircle(
          Offset(
            offsetX + segment.x * cellSize + cellSize / 4,
            offsetY + segment.y * cellSize + cellSize / 4,
          ),
          cellSize / 8,
          eyePaint,
        );
      }
    }
  }

  void _drawUI(Canvas canvas) {
    final textPaint = TextPaint(
      style: const TextStyle(
        color: MGColors.textHighEmphasis,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    // 점수 표시
    textPaint.render(canvas, 'Score: $score', Vector2(20, 20));

    // Battle mode: show opponent score
    if (mode == SnakeGameMode.battle) {
      final oppScorePaint = TextPaint(
        style: const TextStyle(
          color: MGColors.error,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
      oppScorePaint.render(
        canvas,
        'AI: $opponentScore',
        Vector2(size.x - 150, 20),
      );

      // Target score indicator
      final targetPaint = TextPaint(
        style: const TextStyle(
          color: MGColors.textDisabled,
          fontSize: 20,
        ),
      );
      targetPaint.render(
        canvas,
        'Target: 15',
        Vector2(size.x / 2 - 50, 20),
      );
    }

    // Active effect indicator
    if (activeEffect != null && effectTimer != null) {
      final effectPaint = TextPaint(
        style: TextStyle(
          color: activeEffect!.color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: MGColors.backgroundDark),
          ],
        ),
      );

      final remainingSeconds = (effectTimer!.tick ?? 0) / 1000;
      effectPaint.render(
        canvas,
        '${activeEffect!.name}: ${remainingSeconds.toStringAsFixed(1)}s',
        Vector2(20, 60),
      );
    }

    // Time Attack Timer Render
    if (mode == SnakeGameMode.timeAttack) {
      final timerPaint = TextPaint(
        style: TextStyle(
          color: remainingTime <= 10 ? MGColors.error : MGColors.textHighEmphasis,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(offset: Offset(2, 2), blurRadius: 3, color: MGColors.backgroundDark),
          ],
        ),
      );
      timerPaint.render(
        canvas,
        'Time: ${remainingTime.toStringAsFixed(1)}',
        Vector2(size.x - 220, 20),
      );
    }

    // Game Over
    if (gameOver) {
      // Game Over text is now handled by overlay
    }

    // Before start
    if (!gameStarted && !gameOver) {
      final startPaint = TextPaint(
        style: const TextStyle(color: MGColors.textHighEmphasis, fontSize: 32),
      );

      final startMessage = mode == SnakeGameMode.battle
          ? 'Battle Mode! Tap to start'
          : 'Tap or press key to start';

      startPaint.render(
        canvas,
        startMessage,
        Vector2(size.x / 2 - 220, size.y / 2),
      );
    }
  }
}
