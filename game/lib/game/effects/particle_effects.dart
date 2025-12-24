import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
                    Colors.red,
                    Colors.yellow,
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
                    Colors.green,
                    Colors.yellow,
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
