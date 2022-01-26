import 'package:bonfire/bonfire.dart';
import 'package:puzzle/map/map.dart';
import 'package:puzzle/pathfinder/node.dart';

extension TwoDimensionalListExtension on List<List> {
  bool checkBoundaries(int x, int y) =>
      x >= 0 && x < length && y >= 0 && y < first.length;
}

extension ListExtension<T> on List<T> {
  void addToSorted(T element, int Function(T, T) compare) {
    var index = binarySearch(element, compare);
    if (index < 0) {
      index = -index - 1;
    }
    insert(index, element);
  }

  int binarySearch(T element, int Function(T, T) compare) {
    var m = 0;
    var n = length - 1;
    while (m <= n) {
      final k = (m + n) >> 1;
      final cmp = compare(element, this[k]);
      if (cmp > 0) {
        m = k + 1;
      } else if (cmp < 0) {
        n = k - 1;
      } else {
        return k;
      }
    }

    return -m - 1;
  }
}

extension NodeExtensions on Node {
  Vector2 vector2(double tileSize) =>
      GameMap.getRelativeTilePosition(tileSize, x, y);
}

extension Vector2Extensions on Vector2 {
  void addNum(double x, double y) {
    this.x += x;
    this.y += y;
  }

  void subNum(double x, double y) {
    this.x -= x;
    this.y -= y;
  }
}
