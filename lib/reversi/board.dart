import 'dart:io';

import 'package:reversi/reversi/operator.dart';

void main(List<String> args) {
  if (args.length != 3) {
    print('count');
    return;
  }
  var count = int.parse(args[0]);
  var p1 = int.parse(args[1]);
  var p2 = int.parse(args[2]);
  var cpus = [
    CpuRandom(),
  ];
  var players = [cpus[p1], cpus[p2]];

  var winBlack = 0;
  var winWhite = 0;
  var draw = 0;

  for (var i = 0; i < count; i++) {
    var board = Board();

    while (true) {
      var point = board.nextStone == Stone.black
          ? players[0].next(board)
          : players[1].next(board);

      board.put(x: point.x, y: point.y);
      if (board.boardState == BoardState.winBlack) {
        print('win ⚫');
        winBlack++;
        break;
      } else if (board.boardState == BoardState.winWhite) {
        print('win ⚪');
        winWhite++;
        break;
      } else if (board.boardState == BoardState.draw) {
        print('draw');
        draw++;
        break;
      }
    }
  }
  print('⚫$winBlack ⚪$winWhite -$draw');
}

enum Stone {
  black,
  white,
  nothing;

  Stone reverse() {
    switch (this) {
      case black:
        return white;
      case white:
        return black;
      case nothing:
        return nothing;
    }
  }
}

enum BoardState {
  winBlack,
  winWhite,
  draw,
  pending;
}

enum SquareState {
  canPut,
  canNotPut;
}

enum Direction {
  upper(x: 0, y: -1),
  upperRight(x: 1, y: -1),
  right(x: 1, y: 0),
  lowerRight(x: 1, y: 1),
  lower(x: 0, y: 1),
  lowerLeft(x: -1, y: 1),
  left(x: -1, y: 0),
  upeerLeft(x: -1, y: -1);

  const Direction({
    required this.x,
    required this.y,
  });

  final int x;
  final int y;
}

class Square {
  var stone = Stone.nothing;
  var state = SquareState.canNotPut;

  void init() {
    stone = Stone.nothing;
    state = SquareState.canNotPut;
  }
}

class Point {
  final int x;
  final int y;

  const Point({required this.x, required this.y});
}

// 置ける場所のクラス
class PutPoint {
  final Point point;
  final _reversePoints = <Point>[];
  int get count => _reversePoints.length;
  List<Point> get reversePoints => _reversePoints;

  PutPoint({required this.point});

  void addPoint(
      {required int startX,
      required int startY,
      required int endX,
      required int endY,
      required Direction direction}) {
    var x = startX;
    var y = startY;
    while (true) {
      x = x + direction.x;
      y = y + direction.y;
      if (x == endX && y == endY) {
        return;
      }
      _reversePoints.add(Point(x: x, y: y));
    }
  }
}

class Board {
  static const boardWidth = 8;
  static const boardHeight = 8;

  final List<List<Square>> _squares;

  Stone getStone({required int x, required int y}) {
    return _squares[x][y].stone;
  }

  var _countBlack = 0;
  int get countBlack => _countBlack;
  var _countWhite = 0;
  int get countWhite => _countWhite;
  var _boardState = BoardState.pending;
  BoardState get boardState => _boardState;

  var _nextStone = Stone.black;
  Stone get nextStone => _nextStone;
  var _canPutPoints = <PutPoint>[];
  List<PutPoint> get canPutPoints => _canPutPoints;

  var _skipped = false;
  bool get skipped => _skipped;

  Point? _lastPoint;
  Point? get lastPoint => _lastPoint;
  var _lastChanged = <Point>[];
  List<Point> get lastChanged => _lastChanged;

  Board()
      : _squares = List.generate(
            boardWidth, (_) => List.generate(boardHeight, (_) => Square())) {
    _initPut();
  }

  void _initPut() {
    _nextStone = Stone.black;
    for (var inner in _squares) {
      for (var square in inner) {
        square.init();
      }
    }
    _squares[4][3].stone = Stone.black;
    _squares[3][4].stone = Stone.black;
    _squares[3][3].stone = Stone.white;
    _squares[4][4].stone = Stone.white;

    _canCheckPut(stone: _nextStone);
  }

  void restart() {
    _initPut();
  }

  bool canPut({required int x, required int y}) {
    return canPutPoints
        .where((e) => e.point.x == x && e.point.y == y)
        .isNotEmpty;
  }

  bool isLastPoint({required int x, required int y}) {
    return _lastPoint?.x == x && _lastPoint?.y == y;
  }

  bool isLastChanged({required int x, required int y}) {
    return _lastChanged.where((e) => e.x == x && e.y == y).isNotEmpty;
  }

  bool put({required int x, required int y}) {
    // 置けない場合はエラー
    if (_squares[x][y].state == SquareState.canNotPut) {
      return false;
    }

    _skipped = false;
    _putStone(stone: _nextStone, x: x, y: y);

    _nextStone = _nextStone.reverse();
    _canCheckPut(stone: _nextStone);
    if (_boardState == BoardState.pending) {
      var tempList = _squares.expand((e) => e).toList();
      var countCanPut =
          tempList.where((e) => e.state == SquareState.canPut).length;
      if (countCanPut == 0) {
        _skipped = true;
        _nextStone = _nextStone.reverse();
        _canCheckPut(stone: _nextStone);
        // スキップされている状態でスキップされるともう置けないので結果を出す
        tempList = _squares.expand((e) => e).toList();
        countCanPut =
            tempList.where((e) => e.state == SquareState.canPut).length;
        if (countCanPut == 0) {
          if (_countBlack == _countWhite) {
            _boardState = BoardState.draw;
          } else if (_countBlack > _countWhite) {
            _boardState = BoardState.winBlack;
          } else {
            _boardState = BoardState.winWhite;
          }
          return true;
        }
      }
    }
    return true;
  }

  void _putStone({required Stone stone, required int x, required int y}) {
    var putPoint =
        _canPutPoints.where((e) => e.point.x == x && e.point.y == y).first;
    for (var point in putPoint.reversePoints) {
      _squares[point.x][point.y].stone = stone;
    }
    _lastPoint = Point(x: x, y: y);
    _lastChanged = putPoint._reversePoints;
    _squares[x][y].stone = stone;
  }

  void printConsole() {
    for (var y = 0; y < boardHeight; y++) {
      for (var x = 0; x < boardWidth; x++) {
        switch (_squares[x][y].stone) {
          case Stone.black:
            stdout.write('＊');
            break;
          case Stone.white:
            stdout.write('Ｏ');
            break;
          case Stone.nothing:
            if (_squares[x][y].state == SquareState.canPut) {
              stdout.write('・');
            } else {
              stdout.write('＿');
            }
            break;
        }
      }
      print('');
    }
  }

  void _canCheckPut({required Stone stone}) {
    _canPutPoints = [];
    for (var x = 0; x < boardWidth; x++) {
      for (var y = 0; y < boardHeight; y++) {
        if (_squares[x][y].stone != Stone.nothing) {
          _squares[x][y].state = SquareState.canNotPut;
          continue;
        }
        var putPoint = _canCheckPutSquare(stone: stone, x: x, y: y);
        if (putPoint.count > 0) {
          _squares[x][y].state = SquareState.canPut;
          _canPutPoints.add(putPoint);
        } else {
          _squares[x][y].state = SquareState.canNotPut;
        }
      }
    }
    var tempList = _squares.expand((e) => e).toList();
    _countBlack = tempList.where((e) => e.stone == Stone.black).length;
    _countWhite = tempList.where((e) => e.stone == Stone.white).length;
    var countNothing = tempList.where((e) => e.stone == Stone.nothing).length;
    if (countNothing == 0) {
      if (_countBlack == _countWhite) {
        _boardState = BoardState.draw;
      } else if (_countBlack > _countWhite) {
        _boardState = BoardState.winBlack;
      } else {
        _boardState = BoardState.winWhite;
      }
      return;
    }
    _boardState = BoardState.pending;
  }

  PutPoint _canCheckPutSquare(
      {required Stone stone, required int x, required int y}) {
    var putPoint = PutPoint(point: Point(x: x, y: y));
    for (var direction in Direction.values) {
      _canCheckPutSquareDirection(
          stone: stone, x: x, y: y, direction: direction, putPoint: putPoint);
    }
    return putPoint;
  }

  void _canCheckPutSquareDirection(
      {required Stone stone,
      required int x,
      required int y,
      required Direction direction,
      required PutPoint putPoint}) {
    // 初期のxとyを保存
    var originX = x;
    var originY = y;
    bool isFirst = true;
    while (true) {
      x = x + direction.x;
      y = y + direction.y;
      if (_overBoard(x: x, y: y)) {
        return;
      }
      if (_squares[x][y].stone == Stone.nothing) {
        return;
      }
      if (isFirst) {
        // 最初がないか、同じ色だと置けない
        if (_squares[x][y].stone == stone) {
          return;
        }
        isFirst = false;
        continue;
      }
      // 最初以外で同じ色だと置ける
      if (_squares[x][y].stone == stone) {
        putPoint.addPoint(
            startX: originX,
            startY: originY,
            endX: x,
            endY: y,
            direction: direction);
        return;
      }
    }
  }

  bool _overBoard({required int x, required int y}) {
    // 盤の外側は終了
    if (x < 0 || x >= boardWidth) {
      return true;
    }
    if (y < 0 || y >= boardHeight) {
      return true;
    }
    return false;
  }
}
