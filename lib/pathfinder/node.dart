class Node {
  Node(this.x, this.y);

  final int x;
  final int y;
  int f = 0;
  int cost = 0;
  bool closed = false;
  bool checked = false;
  bool wall = true;
  bool occupied = false;
  Node? parent;
  bool hasBox = false;
  bool used = false;
}
