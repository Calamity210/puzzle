import 'dart:io';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:puzzle/game/background.dart';
import 'package:puzzle/game/game.dart';
import 'package:puzzle/game/level.dart';
import 'package:puzzle/map/map.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  double tileSize = 50;
  late final level = Level.newLevel(tileSize, 10, 3);
  late final _futureImage = rootBundle.load('assets/images/dash/dash.png');

  @override
  void initState() {
    if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) {
      tileSize = 100;
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
          return FutureBuilder<ByteData>(
            future: _futureImage,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
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
                  background: Background(
                    color: const Color(0xFF5c5e91),
                    image: img.decodeImage(
                      snapshot.data!.buffer.asUint8List().buffer.asUint8List(),
                    )!,
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      ),
    );
  }
}
