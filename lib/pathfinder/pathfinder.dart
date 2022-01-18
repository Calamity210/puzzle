import 'package:puzzle/game/level.dart';
import 'package:puzzle/pathfinder/node.dart';
import 'package:puzzle/pathfinder/path.dart';
import 'package:puzzle/utils/extensions.dart';

const wallCost = 100;
int pathCost = 1;
int playerPathCost = -1;
const boxCost = 10000;

class Pathfinder {
  Pathfinder(this.level, this.startX, this.startY, this.endX, this.endY);

  final Level level;
  late final nodes = level.nodes;
  final int startX;
  final int startY;
  final int endX;
  final int endY;
  final List<Node> open = [];
  final List<Node> closed = [];

  Path findPath(bool isBox) {
    open.add(nodes[startX][startY]);
    Node? curNode;
    while (open.isNotEmpty) {
      curNode = open.removeAt(0);

      if (curNode.x == endX && curNode.y == endY) {
        open.add(curNode);
        return sumPath(curNode);
      }

      curNode.closed = true;
      closed.add(curNode);
      checkNeighbour(curNode.x + 1, curNode.y, curNode, isBox);
      checkNeighbour(curNode.x - 1, curNode.y, curNode, isBox);
      checkNeighbour(curNode.x, curNode.y + 1, curNode, isBox);
      checkNeighbour(curNode.x, curNode.y - 1, curNode, isBox);
    }

    return sumPath(curNode ?? nodes[startX][startY]);
  }

  Path sumPath(Node node) {
    var endNode = node;

    final path = <Node>[];
    final cost = endNode.cost;

    while (endNode.parent != null) {
      path.insert(0, endNode);
      endNode = endNode.parent!;
    }
    resetNodes();
    return Path(path, cost);
  }

  void checkNeighbour(int x, int y, Node parent, bool isBox) {
    if (nodes.checkBoundaries(x, y)) {
      final curNode = nodes[x][y];

      if (!curNode.closed && !curNode.checked) {
        curNode.cost = calculateCost(curNode, parent, isBox);
        curNode.f = curNode.cost + (x - endX).abs() + (y - endY).abs();
        curNode.parent = parent;
        curNode.checked = true;
        open.addToSorted(curNode, (e1, e2) => e1.f - e2.f);
      } else if (!curNode.closed) {
        final cost = calculateCost(curNode, parent, isBox);
        if (cost < curNode.cost && curNode.parent!.parent != null) {
          curNode.cost = cost;
          curNode.f = curNode.cost + (x - endX).abs() + (y - endY).abs();
          curNode.parent = parent;
        }
      }
    }
  }

  int calculateCost(Node node, Node parent, bool isBox) {
    var tempCost = 0;
    if (node.occupied) {
      tempCost = parent.cost + boxCost;
    } else {
      final cost = isBox ? pathCost : playerPathCost;
      tempCost = node.wall ? parent.cost + wallCost : parent.cost + cost;
    }

    if (isBox && parent.parent != null) {
      var cost1 = 0;
      var cost2 = 0;

      if (node.x - 1 == parent.x && node.x - 2 != parent.parent!.x) {
        if (node.y - 1 == parent.parent!.y) {
          cost1 =
              nodeCost(node.x - 2, node.y) + nodeCost(node.x - 2, node.y - 1);

          cost2 = nodeCost(node.x, node.y - 1) +
              nodeCost(node.x, node.y + 1) +
              nodeCost(node.x - 1, node.y + 1) +
              nodeCost(node.x - 2, node.y + 1) +
              nodeCost(node.x - 2, node.y);
        } else {
          cost1 =
              nodeCost(node.x - 2, node.y) + nodeCost(node.x - 2, node.y + 1);

          cost2 = nodeCost(node.x, node.y - 1) +
              nodeCost(node.x, node.y + 1) +
              nodeCost(node.x - 1, node.y - 1) +
              nodeCost(node.x - 2, node.y - 1) +
              nodeCost(node.x - 2, node.y);
        }
      } else if (node.x + 1 == parent.x && node.x + 2 != parent.parent!.x) {
        if (node.y - 1 == parent.parent!.y) {
          cost1 =
              nodeCost(node.x + 2, node.y) + nodeCost(node.x + 2, node.y - 1);
          cost2 = nodeCost(node.x, node.y - 1) +
              nodeCost(node.x, node.y + 1) +
              nodeCost(node.x + 1, node.y + 1) +
              nodeCost(node.x + 2, node.y + 1) +
              nodeCost(node.x + 2, node.y);
        } else {
          cost1 =
              nodeCost(node.x + 2, node.y) + nodeCost(node.x + 2, node.y + 1);
          cost2 = nodeCost(node.x, node.y - 1) +
              nodeCost(node.x, node.y + 1) +
              nodeCost(node.x + 1, node.y - 1) +
              nodeCost(node.x + 2, node.y - 1) +
              nodeCost(node.x + 2, node.y);
        }
      } else if (node.y - 1 == parent.y && node.y - 2 != parent.parent!.y) {
        if (node.x - 1 == parent.parent!.x) {
          cost1 =
              nodeCost(node.x, node.y - 2) + nodeCost(node.x - 1, node.y - 2);
          cost2 = nodeCost(node.x - 1, node.y) +
              nodeCost(node.x + 1, node.y) +
              nodeCost(node.x + 1, node.y - 1) +
              nodeCost(node.x + 1, node.y - 2) +
              nodeCost(node.x, node.y - 2);
        } else {
          cost1 =
              nodeCost(node.x, node.y - 2) + nodeCost(node.x + 1, node.y - 2);
          cost2 = nodeCost(node.x - 1, node.y) +
              nodeCost(node.x + 1, node.y) +
              nodeCost(node.x - 1, node.y - 1) +
              nodeCost(node.x - 1, node.y - 2) +
              nodeCost(node.x, node.y - 2);
        }
      } else if (node.y + 1 == parent.y && node.y + 2 != parent.parent!.y) {
        if (node.x - 1 == parent.parent!.x) {
          cost1 =
              nodeCost(node.x, node.y + 2) + nodeCost(node.x - 1, node.y + 2);
          cost2 = nodeCost(node.x - 1, node.y) +
              nodeCost(node.x + 1, node.y) +
              nodeCost(node.x + 1, node.y + 1) +
              nodeCost(node.x + 1, node.y + 2) +
              nodeCost(node.x, node.y + 2);
        } else {
          cost1 =
              nodeCost(node.x, node.y + 2) + nodeCost(node.x + 1, node.y + 2);
          cost2 = nodeCost(node.x - 1, node.y) +
              nodeCost(node.x + 1, node.y) +
              nodeCost(node.x - 1, node.y + 1) +
              nodeCost(node.x - 1, node.y + 2) +
              nodeCost(node.x, node.y + 2);
        }
      }
      tempCost += cost1 < cost2 ? cost1 : cost2;
    } else if (isBox) {
      if (node.x - 1 == parent.x) {
        tempCost += nodeCost(node.x - 2, node.y);
      } else if (node.x + 1 == parent.x) {
        tempCost += nodeCost(node.x + 2, node.y);
      } else if (node.y - 1 == parent.y) {
        tempCost += nodeCost(node.x, node.y - 2);
      } else if (node.y + 1 == parent.y) {
        tempCost += nodeCost(node.x, node.y + 2);
      }
    }

    if (node.used) {
      tempCost -= 5;
    }

    return tempCost;
  }

  int nodeCost(int x, int y) {
    if (nodes.checkBoundaries(x, y)) {
      final node = nodes[x][y];
      if (node.occupied) {
        return boxCost;
      }

      return node.wall ? wallCost : playerPathCost;
    }

    return boxCost;
  }

  void resetNodes() {
    for (final node in open) {
      node.checked = false;
      node.closed = false;
      node.parent = null;
      node.cost = 0;
    }

    for (final node in closed) {
      node.checked = false;
      node.closed = false;
      node.parent = null;
      node.cost = 0;
    }
  }
}
