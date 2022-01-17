import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/player/dash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }

  Level.newLevel(10, 3);
  print(Level.currentLevel!.player.x);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(
          isFixed: false,
        ),
      ),
      map: GameMap.map(),
      player: Level.currentLevel!.player,
      // decorations: GameMap.decorations(),
      lightingColorGame: Colors.black.withOpacity(0.75),
    );
  }
}
