import 'dart:math';
import 'dart:ui';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

mixin CustomMoveToPositionAlongThePath on Movement {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;
  static const REDUCTION_TO_AVOID_ROUNDING_PROBLEMS = 4;

  List<Offset> _currentPath = [];
  int _currentIndex = 0;
  bool _showBarriers = false;
  bool _gridSizeIsCollisionSize = false;

  final List<Offset> _barriers = [];
  List ignoreCollisions = [];

  Color _pathLineColor = const Color(0xFF40C4FF).withOpacity(0.5);
  double _pathLineStrokeWidth = 4;

  final Paint _paintShowBarriers = Paint()
    ..color = const Color(0xFF2196F3).withOpacity(0.5);

  void setupMoveToPositionAlongThePath({
    Color? pathLineColor,
    Color? barriersCalculatedColor,
    double pathLineStrokeWidth = 4,
    bool showBarriersCalculated = false,
    bool gridSizeIsCollisionSize = false,
  }) {
    _paintShowBarriers.color =
        barriersCalculatedColor ?? const Color(0xFF2196F3).withOpacity(0.5);
    _showBarriers = showBarriersCalculated;
    _pathLineColor = pathLineColor ?? const Color(0xFF40C4FF).withOpacity(0.5);
    _pathLineStrokeWidth = pathLineStrokeWidth;
    _gridSizeIsCollisionSize = gridSizeIsCollisionSize;
  }

  void moveToPositionAlongThePath(Vector2 position, {List? ignoreCollisions}) {
    this.ignoreCollisions.clear();
    this.ignoreCollisions.add(this);
    if (ignoreCollisions != null) {
      this.ignoreCollisions.addAll(ignoreCollisions);
    }

    _currentIndex = 0;
    _calculatePath(position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_currentPath.isNotEmpty) {
      _move(dt);
    }
  }

  @override
  void render(Canvas c) {
    if (_showBarriers) {
      for (final barrier in _barriers) {
        c.drawRect(
          Rect.fromLTWH(
            barrier.dx * _tileSize,
            barrier.dy * _tileSize,
            _tileSize,
            _tileSize,
          ),
          _paintShowBarriers,
        );
      }
    }
    super.render(c);
  }

  void stopMoveAlongThePath() {
    _currentPath.clear();
    _currentIndex = 0;
    idle();
    gameRef.map.setLinePath(_currentPath, _pathLineColor, _pathLineStrokeWidth);
  }

  void _move(double dt) {
    final innerSpeed = speed * dt;
    var center = this.center;
    if (isObjectCollision()) {
      center = (this as ObjectCollision).rectCollision.center.toVector2();
    }
    final diffX = _currentPath[_currentIndex].dx - center.x;
    final diffY = _currentPath[_currentIndex].dy - center.y;
    final displacementX = diffX.abs() > innerSpeed ? speed : diffX.abs() / dt;
    final displacementY = diffY.abs() > innerSpeed ? speed : diffY.abs() / dt;

    if (diffX.abs() < 0.01 && diffY.abs() < 0.01) {
      _goToNextPosition();
    } else {
      var onMove = false;
      if (diffX.abs() > 0.01 && diffY.abs() > 0.01) {
        final displacementXDiagonal = displacementX * REDUCTION_SPEED_DIAGONAL;
        final displacementYDiagonal = displacementY * REDUCTION_SPEED_DIAGONAL;
        if (diffX > 0 && diffY > 0) {
          onMove = moveDownRight(displacementXDiagonal, displacementYDiagonal);
        } else if (diffX < 0 && diffY > 0) {
          onMove = moveDownLeft(displacementXDiagonal, displacementYDiagonal);
        } else if (diffX > 0 && diffY < 0) {
          onMove = moveUpRight(displacementXDiagonal, displacementYDiagonal);
        } else if (diffX < 0 && diffY < 0) {
          onMove = moveUpLeft(displacementXDiagonal, displacementYDiagonal);
        }
      } else if (diffX.abs() > 0.01) {
        if (diffX > 0) {
          onMove = moveRight(displacementX);
        } else if (diffX < 0) {
          onMove = moveLeft(displacementX);
        }
      } else if (diffY.abs() > 0.01) {
        if (diffY > 0) {
          onMove = moveDown(displacementY);
        } else if (diffY < 0) {
          onMove = moveUp(displacementY);
        }
      }

      if (!onMove) {
        _goToNextPosition();
      }
    }
  }

  void _calculatePath(Vector2 finalPosition) {
    final player = this;

    final positionPlayer = player is ObjectCollision
        ? (player as ObjectCollision).rectCollision.center.toVector2()
        : player.center;

    final playerPosition = _getCenterPositionByTile(positionPlayer);
    final targetPosition = _getCenterPositionByTile(finalPosition);
    final columnsAdditional = ((gameRef.size.x / 2) / _tileSize).floor();
    final rowsAdditional = ((gameRef.size.y / 2) / _tileSize).floor();

    final rows =
        max(playerPosition.dy, targetPosition.dy).toInt() + rowsAdditional;

    final columns =
        max(playerPosition.dx, targetPosition.dx).toInt() + columnsAdditional;

    _barriers.clear();

    gameRef.visibleCollisions().forEach((e) {
      if (!ignoreCollisions.contains(e)) {
        _addCollisionOffsetsPositionByTile(e.rectCollision);
      }
    });

    Iterable<Offset> result = [];

    if (_barriers.contains(targetPosition)) {
      stopMoveAlongThePath();
      return;
    }

    try {
      result = AStar(
        rows: rows + 1,
        columns: columns + 1,
        start: playerPosition,
        end: targetPosition,
        barriers: _barriers,
      ).findThePath();

      if (result.isNotEmpty || _isNeighbor(playerPosition, targetPosition)) {
        result = AStar.resumePath(result);
        _currentPath = result.map((e) {
          return Offset(e.dx * _tileSize, e.dy * _tileSize)
              .translate(_tileSize / 2, _tileSize / 2);
        }).toList();

        _currentIndex = 0;
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERROR(AStar):$e');
      }
    }
    gameRef.map.setLinePath(_currentPath, _pathLineColor, _pathLineStrokeWidth);
  }

  double get _tileSize {
    var tileSize = 0.0;
    if (gameRef.map.tiles.isNotEmpty) {
      tileSize = gameRef.map.tiles.first.width;
    }
    if (_gridSizeIsCollisionSize) {
      if (isObjectCollision()) {
        return max(
          (this as ObjectCollision).rectCollision.width,
          (this as ObjectCollision).rectCollision.height,
        );
      }
      return max(height, width) + REDUCTION_TO_AVOID_ROUNDING_PROBLEMS;
    }
    return tileSize;
  }

  bool get isMovingAlongThePath => _currentPath.isNotEmpty;

  Offset _getCenterPositionByTile(Vector2 center) {
    return Offset(
      (center.x / _tileSize).floor().toDouble(),
      (center.y / _tileSize).floor().toDouble(),
    );
  }

  void _addCollisionOffsetsPositionByTile(Rect rect) {
    final leftTop = Offset(
      (rect.left / _tileSize).floor() * _tileSize,
      (rect.top / _tileSize).floor() * _tileSize,
    );

    final grid = <Rect>[];
    final countColumns = (rect.width / _tileSize).ceil() + 1;
    final countRows = (rect.height / _tileSize).ceil() + 1;

    List.generate(countRows, (r) {
      List.generate(countColumns, (c) {
        grid.add(
          Rect.fromLTWH(
            leftTop.dx +
                (c * _tileSize) +
                REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
            leftTop.dy +
                (r * _tileSize) +
                REDUCTION_TO_AVOID_ROUNDING_PROBLEMS / 2,
            _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
            _tileSize - REDUCTION_TO_AVOID_ROUNDING_PROBLEMS,
          ),
        );
      });
    });

    final listRect = grid.where((element) {
      return rect.overlaps(element);
    }).toList();

    final result = listRect.map((e) {
      return Offset(
        (e.center.dx / _tileSize).floorToDouble(),
        (e.center.dy / _tileSize).floorToDouble(),
      );
    }).toList();

    for (final barrier in result) {
      if (!_barriers.contains(barrier)) {
        _barriers.add(barrier);
      }
    }
  }

  bool _isNeighbor(Offset playerPosition, Offset targetPosition) {
    if ((playerPosition.dx - targetPosition.dx).abs() == 1) {
      return true;
    }
    if ((playerPosition.dy - targetPosition.dy).abs() == 1) {
      return true;
    }
    return false;
  }

  void _goToNextPosition() {
    if (_currentIndex < _currentPath.length - 1) {
      _currentIndex++;
    } else {
      stopMoveAlongThePath();
    }
  }
}
