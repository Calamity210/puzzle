import 'dart:io';

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

  if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
    GameMap.tileSize = 100;
  }

  Level.newLevel(10, 3);

  runApp(const MaterialApp(home: GamePage()));
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  @override
  void initState() {
    super.initState();
    Level.newLevel(10, 3);
  }

  late Level lvl = Level.currentLevel;
  late double x = lvl.playerStartX * GameMap.tileSize;
  late double y = lvl.playerStartY * GameMap.tileSize;

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(isFixed: false),
        actions: [
          JoystickAction(
            actionId: 1,
            size: 80,
            margin: const EdgeInsets.only(bottom: 50, right: 50),
          ),
        ],
      ),
      map: GameMap.map(),
      player: Dash(Vector2(x, y)),
      decorations: GameMap.decorations(),
      lightingColorGame: Colors.black.withOpacity(0.75),
    );
  }
}
