import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Animated score popup when eating food
class ScorePopup extends PositionComponent {
  final int points;
  double _elapsed = 0;
  static const double _duration = 1.0;
  static const double _riseSpeed = 60.0;

  ScorePopup({
    required Vector2 position,
    this.points = 1,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    // Rise upward and drift slightly
    position.y -= _riseSpeed * dt;
    position.x += (0.5 - (_elapsed / _duration)) * 10 * dt;

    // Remove after duration
    if (_elapsed >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Calculate opacity based on elapsed time
    final progress = _elapsed / _duration;
    final opacity = 1.0 - progress;
    final scale = 1.0 + progress * 0.5; // Slight scale up

    // Create fading text paint
    final fadingPaint = TextPaint(
      style: TextStyle(
        color: Colors.yellow.withValues(alpha: opacity),
        fontSize: 32 * scale,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(2, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: opacity * 0.5),
          ),
        ],
      ),
    );

    fadingPaint.render(
      canvas,
      '+$points',
      Vector2.zero(),
      anchor: Anchor.center,
    );
  }
}
