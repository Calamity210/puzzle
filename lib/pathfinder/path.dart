import 'package:puzzle/pathfinder/node.dart';

class Path {
  Path(this.path, this.cost);

  final List<Node> path;
  final int cost;
}

class Paths {
  Paths(this.paths, this.bestPath);

  final List<Path> paths;
  final int bestPath;
}
