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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Level lvl = Level.currentLevel;
  late double x = lvl.playerStartX * GameMap.tileSize;
  late double y = lvl.playerStartY * GameMap.tileSize;
  var map = GameMap.map();
  late var dash = Dash(Vector2(x, y), restart);

  void restart() {
    setState(() {
      lvl = Level.currentLevel;
      x = lvl.playerStartX * GameMap.tileSize;
      y = lvl.playerStartY * GameMap.tileSize;
      Level.newLevel(10, 3);
      map = GameMap.map();
      dash = Dash(Vector2(x, y), restart);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(
          isFixed: false,
        ),
        actions: [
          JoystickAction(
            actionId: 1,
            size: 80,
            margin: const EdgeInsets.only(bottom: 50, right: 50),
          ),
        ],
      ),
      map: map,
      player: dash,
      decorations: GameMap.decorations(),
      lightingColorGame: Colors.black.withOpacity(0.75),
    );
  }
}
