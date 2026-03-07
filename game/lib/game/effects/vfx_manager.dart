/// VFX Manager for MG-0009 Snake Game
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:mg_common_game/core/engine/effects/flame_effects.dart';

class VfxManager extends Component {
  VfxManager();

  Component? _gameRef;

  void setGame(Component game) {
    _gameRef = game;
  }

  void _addEffect(Component effect) {
    _gameRef?.add(effect);
  }

  /// Show food eat effect
  void showFoodEat(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.red,
          radius: 25.0,
        ),
    );
  }

  /// Show bonus food eat effect
  void showBonusFoodEat(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.amber,
          radius: 30.0,
        ),
    );
  }

  /// Show snake grow effect
  void showGrow(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.green,
          radius: 20.0,
        ),
    );
  }

  /// Show wall collision effect
  void showWallCollision(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.red,
          radius: 40.0,
        ),
    );
  }

  /// Show self collision effect
  void showSelfCollision(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.orange,
          radius: 35.0,
        ),
    );
  }

  /// Show score milestone effect
  void showMilestone(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.purple,
          radius: 50.0,
        ),
    );
  }

  /// Show speed up warning effect
  void showSpeedUp(Vector2 position) {
    _addEffect(
      FlameParticleEffect.explosion(
          position: position.clone(),
          color: Colors.cyan,
          radius: 30.0,
        ),
    );
  }
}
