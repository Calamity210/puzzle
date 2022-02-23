import 'dart:io';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle/utils/colors.dart';
import 'package:puzzle/game/game.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    required this.mapSize,
    required this.boxCount,
    Key? key,
  }) : super(key: key);

  final int mapSize;
  final int boxCount;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  double tileSize = 60;
  late final level = Level.newLevel(tileSize, widget.mapSize, widget.boxCount);

  @override
  void initState() {
    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
      tileSize = 90;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Game>(
      create: (_) => Game(
        level: level,
        map: GameMap(level: level, tileSize: tileSize),
      ),
      child: Consumer<Game>(
        builder: (context, game, child) {
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
            map: game.map.map,
            player: game.level.player,
            decorations: game.map.boxes,
            background: BackgroundColorGame(AppColors.purple),
          );
        },
      ),
    );
  }
}
