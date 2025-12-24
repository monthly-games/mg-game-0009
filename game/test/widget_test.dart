import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    GetIt.I.reset();
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  });

  testWidgets('SnakeGameApp smoke test', (WidgetTester tester) async {
    // Set realistic size
    await tester.binding.setSurfaceSize(const Size(800, 600));

    await tester.pumpWidget(const SnakeGameApp());
    await tester.pumpAndSettle();

    expect(find.text('SNAKE'), findsOneWidget);
    expect(find.text('NORMAL'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
  });
}
