import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import '../skin_manager.dart';

/// Food collection particle effect
class FoodParticleEffect extends Component {
  final Vector2 position;
  final Random _random = Random();

  FoodParticleEffect({required this.position});

  @override
  Future<void> onLoad() async {
    // Create star-burst particles
    final particles = List.generate(
      12,
      (i) {
        final angle = (i / 12) * 2 * pi;
        final speed = 80.0 + _random.nextDouble() * 60.0;

        return Particle.generate(
          count: 1,
          lifespan: 0.6,
          generator: (i) {
            return AcceleratedParticle(
              speed: Vector2(
                cos(angle) * speed,
                sin(angle) * speed,
              ),
              acceleration: Vector2(0, 150),
              child: CircleParticle(
                radius: 3.0 + _random.nextDouble() * 2.0,
                paint: Paint()
                  ..color = Color.lerp(
                    MGColors.error,
                    MGColors.gold,
                    _random.nextDouble(),
                  )!,
              ),
            );
          },
        );
      },
    );

    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 1,
          generator: (i) => ComposedParticle(children: particles),
        ),
      ),
    );

    // Remove this component after particles are done
    Future.delayed(const Duration(milliseconds: 700), () {
      removeFromParent();
    });
  }
}

/// Game over collision particle effect
class GameOverParticleEffect extends Component {
  final Vector2 position;
  final Random _random = Random();

  GameOverParticleEffect({required this.position});

  @override
  Future<void> onLoad() async {
    // Create explosion particles
    final particles = List.generate(
      20,
      (i) {
        final angle = _random.nextDouble() * 2 * pi;
        final speed = 100.0 + _random.nextDouble() * 100.0;

        return Particle.generate(
          count: 1,
          lifespan: 0.9,
          generator: (i) {
            return AcceleratedParticle(
              speed: Vector2(
                cos(angle) * speed,
                sin(angle) * speed,
              ),
              acceleration: Vector2(0, 200),
              child: CircleParticle(
                radius: 4.0 + _random.nextDouble() * 3.0,
                paint: Paint()
                  ..color = Color.lerp(
                    MGColors.success,
                    MGColors.gold,
                    _random.nextDouble(),
                  )!,
              ),
            );
          },
        );
      },
    );

    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 1,
          generator: (i) => ComposedParticle(children: particles),
        ),
      ),
    );

    // Remove this component after particles are done
    Future.delayed(const Duration(milliseconds: 1000), () {
      removeFromParent();
    });
  }
}

/// Power-up activation particle effect
class PowerUpParticleEffect extends Component {
  final Vector2 position;
  final FoodType type;
  final Random _random = Random();

  PowerUpParticleEffect({required this.position, required this.type});

  @override
  Future<void> onLoad() async {
    final particleCount = type == FoodType.invincibility ? 20 : 15;
    final baseColor = type.color;

    final particles = List.generate(
      particleCount,
      (i) {
        final angle = (i / particleCount) * 2 * pi;
        final speed = 120.0 + _random.nextDouble() * 80.0;

        return Particle.generate(
          count: 1,
          lifespan: 0.8,
          generator: (i) {
            return AcceleratedParticle(
              speed: Vector2(
                cos(angle) * speed,
                sin(angle) * speed,
              ),
              acceleration: Vector2(0, 100),
              child: CircleParticle(
                radius: type == FoodType.invincibility ? 5.0 : 4.0,
                paint: Paint()
                  ..color = Color.lerp(
                    baseColor,
                    MGColors.gold,
                    _random.nextDouble(),
                  )!,
              ),
            );
          },
        );
      },
    );

    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 1,
          generator: (i) => ComposedParticle(children: particles),
        ),
      ),
    );

    // Add spiral effect for invincibility
    if (type == FoodType.invincibility) {
      for (int ring = 0; ring < 3; ring++) {
        final ringParticles = List.generate(
          8,
          (i) {
            final angle = (i / 8) * 2 * pi;
            final speed = 60.0 + ring * 20.0;

            return Particle.generate(
              count: 1,
              lifespan: 1.0 - ring * 0.2,
              generator: (i) {
                return AcceleratedParticle(
                  speed: Vector2(
                    cos(angle) * speed,
                    sin(angle) * speed,
                  ),
                  acceleration: Vector2(0, 50),
                  child: CircleParticle(
                    radius: 3.0,
                    paint: Paint()
                      ..color = HSVColor.fromAHSV(
                        1.0,
                        (i / 8) * 360,
                        1.0,
                        1.0,
                      ).toColor(),
                  ),
                );
              },
            );
          },
        );

        Future.delayed(Duration(milliseconds: ring * 100), () {
          add(
            ParticleSystemComponent(
              position: position,
              particle: Particle.generate(
                count: 1,
                generator: (i) => ComposedParticle(children: ringParticles),
              ),
            ),
          );
        });
      }
    }

    // Remove this component after particles are done
    Future.delayed(const Duration(milliseconds: 1200), () {
      removeFromParent();
    });
  }
}
