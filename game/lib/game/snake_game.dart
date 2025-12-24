import 'dart:async';
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

enum Direction { up, down, left, right }

enum SnakeGameMode { normal, hard, timeAttack }

class SnakeGame extends FlameGame with KeyboardEvents, DragCallbacks {
  final SnakeGameMode mode;
  final VoidCallback? onGameOver;

  SnakeGame({this.mode = SnakeGameMode.normal, this.onGameOver});

  AudioManager get _audioManager => GetIt.I<AudioManager>();
  SkinManager get _skinManager => GetIt.I<SkinManager>();
  // 스와이프 감지를 위한 변수
  Vector2? _dragStart;
  static const double swipeThreshold = 50.0; // 최소 스와이프 거리
  static const int gridSize = 20; // 그리드 크기

  // Mode-based settings
  double get moveInterval {
    switch (mode) {
      case SnakeGameMode.hard:
        return 0.08;
      case SnakeGameMode.timeAttack:
        return 0.12;
      case SnakeGameMode.normal:
        return 0.15;
    }
  }

  List<Vector2> snake = []; // 뱀의 몸통 (그리드 좌표)
  Vector2 food = Vector2.zero(); // 먹이 위치
  Direction currentDirection = Direction.right;
  Direction nextDirection = Direction.right;

  double moveTimer = 0;
  int score = 0;
  bool gameOver = false;
  bool gameStarted = false;
  bool isNewRecord = false;

  // Time Attack logic
  double remainingTime = 60.0;

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
    // 뱀 초기 위치 (중앙, 3칸)
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

    _spawnFood();
  }

  void _spawnFood() {
    // 뱀이 없는 랜덤 위치에 먹이 생성
    bool validPosition = false;
    while (!validPosition) {
      food = Vector2(
        (Vector2.random().x * gridSize).floor().toDouble(),
        (Vector2.random().y * gridSize).floor().toDouble(),
      );

      // 뱀과 겹치지 않는지 확인
      validPosition = !snake.any((segment) => segment == food);
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
    // 방향 업데이트 (다음 방향으로)
    currentDirection = nextDirection;

    // 머리의 새 위치 계산
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

    // 벽 충돌 체크
    if (newHead.x < 0 ||
        newHead.x >= gridSize ||
        newHead.y < 0 ||
        newHead.y >= gridSize) {
      _endGame();
      return;
    }

    // 자기 자신과 충돌 체크
    if (snake.any((segment) => segment == newHead)) {
      _endGame();
      return;
    }

    // 새 머리 추가
    snake.insert(0, newHead);

    // 먹이 먹었는지 확인
    if (newHead == food) {
      score++;
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
      add(ScorePopup(position: foodPixelPos, points: 1));

      _spawnFood();
      // 꼬리는 제거하지 않음 (뱀이 길어짐)
    } else {
      // 꼬리 제거 (길이 유지)
      snake.removeLast();
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

    // 방향 전환 (180도 회전은 불가)
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

    // velocity를 사용하여 방향 판단
    final velocity = event.velocity;

    // 속도가 너무 작으면 무시
    if (velocity.length < 100) {
      _dragStart = null;
      return;
    }

    // 가로/세로 중 더 큰 방향으로 판단
    if (velocity.x.abs() > velocity.y.abs()) {
      // 가로 스와이프
      if (velocity.x > 0 && currentDirection != Direction.left) {
        nextDirection = Direction.right;
        _audioManager.playSfx('turn.wav');
      } else if (velocity.x < 0 && currentDirection != Direction.right) {
        nextDirection = Direction.left;
        _audioManager.playSfx('turn.wav');
      }
    } else {
      // 세로 스와이프
      if (velocity.y > 0 && currentDirection != Direction.up) {
        nextDirection = Direction.down;
        _audioManager.playSfx('turn.wav');
      } else if (velocity.y < 0 && currentDirection != Direction.down) {
        nextDirection = Direction.up;
        _audioManager.playSfx('turn.wav');
      }
    }

    // 게임 시작 (터치로 시작 가능)
    if (!gameStarted && !gameOver) {
      gameStarted = true;
    }

    _dragStart = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 게임 보드 중앙 정렬을 위한 오프셋
    final boardSize = gridSize * cellSize;
    final offsetX = (size.x - boardSize) / 2;
    final offsetY = (size.y - boardSize) / 2;

    // 그리드 그리기 (옅은 선)
    _drawGrid(canvas, offsetX, offsetY);

    // 먹이 그리기
    _drawFood(canvas, offsetX, offsetY);

    // 뱀 그리기
    _drawSnake(canvas, offsetX, offsetY);

    // UI 텍스트
    _drawUI(canvas);
  }

  void _drawGrid(Canvas canvas, double offsetX, double offsetY) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
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
    if (_foodSpriteSheet != null) {
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

    // Fallback logic
    Color foodColor = Colors.red;
    switch (_skinManager.currentFoodSkin) {
      case FoodSkin.apple:
        foodColor = Colors.red;
        break;
      case FoodSkin.mouse:
        foodColor = Colors.grey;
        break;
      case FoodSkin.burger:
        foodColor = Colors.orange;
        break;
      case FoodSkin.diamond:
        foodColor = Colors.cyan;
        break;
      case FoodSkin.coin:
        foodColor = Colors.amber;
        break;
      case FoodSkin.potion:
        foodColor = Colors.purple;
        break;
    }

    final paint = Paint()..color = foodColor;

    final rect = Rect.fromLTWH(
      offsetX + food.x * cellSize + 2,
      offsetY + food.y * cellSize + 2,
      cellSize - 4,
      cellSize - 4,
    );

    canvas.drawOval(rect, paint);
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
        } else if (diff.x < 0)
          rotation = 3.14159;
        else if (diff.y > 0)
          rotation = 1.5708;
        else if (diff.y < 0)
          rotation = 4.71239;
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
        final eyePaint = Paint()..color = Colors.white;
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
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    // 점수 표시
    textPaint.render(canvas, '점수: $score', Vector2(20, 20));

    // Time Attack Timer Render
    if (mode == SnakeGameMode.timeAttack) {
      final timerPaint = TextPaint(
        style: TextStyle(
          color: remainingTime <= 10 ? Colors.red : Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(offset: Offset(2, 2), blurRadius: 3, color: Colors.black),
          ],
        ),
      );
      timerPaint.render(
        canvas,
        '시간: ${remainingTime.toStringAsFixed(1)}',
        Vector2(size.x - 220, 20),
      );
    }

    // 게임 오버
    if (gameOver) {
      // Game Over text is now handled by overlay
    }

    // 시작 전 안내
    if (!gameStarted && !gameOver) {
      final startPaint = TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 32),
      );

      startPaint.render(
        canvas,
        '화면을 터치하거나 키를 눌러 시작',
        Vector2(size.x / 2 - 220, size.y / 2),
      );
    }
  }
}
