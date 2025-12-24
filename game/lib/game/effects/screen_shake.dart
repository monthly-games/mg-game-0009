import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'dart:math';

/// Screen shake effect for game over
class ScreenShakeEffect extends Component {
  final FlameGame game;
  final double intensity;
  final double duration;

  double _elapsed = 0;
  final Random _random = Random();
  Vector2? _originalPosition;

  ScreenShakeEffect({
    required this.game,
    this.intensity = 10.0,
    this.duration = 0.3,
  });

  @override
  void update(double dt) {
    super.update(dt);

    _originalPosition ??= game.camera.viewfinder.position.clone();

    _elapsed += dt;

    if (_elapsed < duration) {
      // Calculate shake offset with decreasing intensity
      final progress = _elapsed / duration;
      final currentIntensity = intensity * (1 - progress);

      final offsetX = (_random.nextDouble() - 0.5) * 2 * currentIntensity;
      final offsetY = (_random.nextDouble() - 0.5) * 2 * currentIntensity;

      game.camera.viewfinder.position = _originalPosition! + Vector2(offsetX, offsetY);
    } else {
      // Reset to original position
      game.camera.viewfinder.position = _originalPosition!;
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    if (_originalPosition != null) {
      game.camera.viewfinder.position = _originalPosition!;
    }
  }
}
