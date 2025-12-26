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
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.red,
        particleCount: 12,
        duration: 0.4,
        spreadRadius: 25.0,
      ),
    );
  }

  /// Show bonus food eat effect
  void showBonusFoodEat(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.amber,
        particleCount: 18,
        duration: 0.5,
        spreadRadius: 30.0,
      ),
    );
  }

  /// Show snake grow effect
  void showGrow(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.green,
        particleCount: 8,
        duration: 0.3,
        spreadRadius: 20.0,
      ),
    );
  }

  /// Show wall collision effect
  void showWallCollision(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.red,
        particleCount: 25,
        duration: 0.6,
        spreadRadius: 40.0,
      ),
    );
  }

  /// Show self collision effect
  void showSelfCollision(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.orange,
        particleCount: 20,
        duration: 0.5,
        spreadRadius: 35.0,
      ),
    );
  }

  /// Show score milestone effect
  void showMilestone(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.purple,
        particleCount: 30,
        duration: 0.8,
        spreadRadius: 50.0,
      ),
    );
  }

  /// Show speed up warning effect
  void showSpeedUp(Vector2 position) {
    _addEffect(
      FlameParticleEffect(
        position: position.clone(),
        color: Colors.cyan,
        particleCount: 15,
        duration: 0.4,
        spreadRadius: 30.0,
      ),
    );
  }
}
