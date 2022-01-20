import 'dart:io';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';

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

  @override
  Widget build(BuildContext context) {
    GameMap.getBoxes();

    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(isFixed: false),
        actions: [
          JoystickAction(
            actionId: 'help',
            sprite: Sprite.load('box_help.png'),
            size: 80,
            margin: const EdgeInsets.only(bottom: 50, right: 50),
          ),
          JoystickAction(
            actionId: 'restart',
            sprite: Sprite.load('restart.png'),
            margin: const EdgeInsets.only(top: 25, left: 25),
            align: JoystickActionAlign.TOP_LEFT,
          ),
        ],
      ),
      map: GameMap.map(),
      player: Level.current.player,
      decorations: GameMap.boxes,
      lightingColorGame: Colors.black.withOpacity(0.75),
    );
  }
}
