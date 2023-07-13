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
    var reversi = Reversi();

    while (true) {
      var point = reversi.nextStone == Stone.black
          ? players[0].next(reversi.currentBoard)
          : players[1].next(reversi.currentBoard);

      reversi.put(x: point.x, y: point.y);
      if (reversi.boardState == BoardState.winBlack) {
        print('win ⚫');
        winBlack++;
        break;
      } else if (reversi.boardState == BoardState.winWhite) {
        print('win ⚪');
        winWhite++;
        break;
      } else if (reversi.boardState == BoardState.draw) {
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

  Square clone() {
    var square = Square();
    square.stone = stone;
    square.state = state;
    return square;
  }

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

  final List<List<Square>> squares;
  var _countBlack = 0;
  var _countWhite = 0;

  var _boardState = BoardState.pending;
  var _nextStone = Stone.black;
  var _canPutPoints = <PutPoint>[];
  var _skipped = false;
  Point? _lastPoint;
  var _lastChanged = <Point>[];

  int get countBlack => _countBlack;
  int get countWhite => _countWhite;
  BoardState get boardState => _boardState;

  Stone get nextStone => _nextStone;
  List<PutPoint> get canPutPoints => _canPutPoints;

  bool get skipped => _skipped;

  Point? get lastPoint => _lastPoint;
  List<Point> get lastChanged => _lastChanged;

  Stone getStone({required int x, required int y}) {
    return squares[x][y].stone;
  }

  bool canPut({required int x, required int y}) {
    return _canPutPoints
        .where((e) => e.point.x == x && e.point.y == y)
        .isNotEmpty;
  }

  bool isLastPoint({required int x, required int y}) {
    return _lastPoint?.x == x && _lastPoint?.y == y;
  }

  bool isLastChanged({required int x, required int y}) {
    return _lastChanged.where((e) => e.x == x && e.y == y).isNotEmpty;
  }

  Board()
      : squares = List.generate(
            boardWidth, (_) => List.generate(boardHeight, (_) => Square()));

  Board.clone(Board newBoard)
      : squares = List.generate(
            boardWidth, (_) => List.generate(boardHeight, (_) => Square())) {
    for (var i = 0; i < newBoard.squares.length; i++) {
      for (var j = 0; j < newBoard.squares[i].length; j++) {
        squares[i][j] = newBoard.squares[i][j].clone();
      }
    }
    _boardState = newBoard._boardState;
    _nextStone = newBoard._nextStone;
    _canPutPoints = newBoard._canPutPoints;
    _skipped = false;
  }
}

class Reversi {
  final _boards = <Board>[];
  var _currentIndex = 0;
  late Board _currentBoard;

  int get countBlack => _currentBoard._countBlack;
  int get countWhite => _currentBoard._countWhite;
  BoardState get boardState => _currentBoard._boardState;

  Stone get nextStone => _currentBoard._nextStone;
  List<PutPoint> get canPutPoints => _currentBoard._canPutPoints;

  bool get skipped => _currentBoard._skipped;

  Point? get lastPoint => _currentBoard._lastPoint;
  List<Point> get lastChanged => _currentBoard._lastChanged;

  Board get currentBoard => _currentBoard;

  Reversi() {
    _boards.add(Board());
    _currentBoard = _boards[_currentIndex];
    _initPut();
  }

  void _initPut() {
    _currentBoard._nextStone = Stone.black;
    for (var inner in _currentBoard.squares) {
      for (var square in inner) {
        square.init();
      }
    }
    _currentBoard.squares[4][3].stone = Stone.black;
    _currentBoard.squares[3][4].stone = Stone.black;
    _currentBoard.squares[3][3].stone = Stone.white;
    _currentBoard.squares[4][4].stone = Stone.white;

    _canCheckPut(stone: _currentBoard._nextStone);
  }

  void restart() {
    _initPut();
  }

  bool put({required int x, required int y}) {
    // 置けない場合はエラー
    if (_currentBoard.squares[x][y].state == SquareState.canNotPut) {
      return false;
    }
    _currentIndex++;
    _boards.add(Board.clone(currentBoard));
    _currentBoard = _boards[_currentIndex];

    _currentBoard._skipped = false;
    _putStone(stone: _currentBoard._nextStone, x: x, y: y);

    _currentBoard._nextStone = _currentBoard._nextStone.reverse();
    _canCheckPut(stone: _currentBoard._nextStone);
    if (_currentBoard._boardState == BoardState.pending) {
      var tempList = _currentBoard.squares.expand((e) => e).toList();
      var countCanPut =
          tempList.where((e) => e.state == SquareState.canPut).length;
      if (countCanPut == 0) {
        _currentBoard._skipped = true;
        _currentBoard._nextStone = _currentBoard._nextStone.reverse();
        _canCheckPut(stone: _currentBoard._nextStone);
        // スキップされている状態でスキップされるともう置けないので結果を出す
        tempList = _currentBoard.squares.expand((e) => e).toList();
        countCanPut =
            tempList.where((e) => e.state == SquareState.canPut).length;
        if (countCanPut == 0) {
          if (_currentBoard._countBlack == _currentBoard._countWhite) {
            _currentBoard._boardState = BoardState.draw;
          } else if (_currentBoard._countBlack > _currentBoard._countWhite) {
            _currentBoard._boardState = BoardState.winBlack;
          } else {
            _currentBoard._boardState = BoardState.winWhite;
          }
          return true;
        }
      }
    }
    return true;
  }

  void _putStone({required Stone stone, required int x, required int y}) {
    var putPoint = _currentBoard._canPutPoints
        .where((e) => e.point.x == x && e.point.y == y)
        .first;
    for (var point in putPoint.reversePoints) {
      _currentBoard.squares[point.x][point.y].stone = stone;
    }
    _currentBoard._lastPoint = Point(x: x, y: y);
    _currentBoard._lastChanged = putPoint._reversePoints;
    _currentBoard.squares[x][y].stone = stone;
  }

  void printConsole() {
    for (var y = 0; y < Board.boardHeight; y++) {
      for (var x = 0; x < Board.boardWidth; x++) {
        switch (_currentBoard.squares[x][y].stone) {
          case Stone.black:
            stdout.write('＊');
            break;
          case Stone.white:
            stdout.write('Ｏ');
            break;
          case Stone.nothing:
            if (_currentBoard.squares[x][y].state == SquareState.canPut) {
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
    _currentBoard._canPutPoints = [];
    for (var x = 0; x < Board.boardWidth; x++) {
      for (var y = 0; y < Board.boardHeight; y++) {
        if (_currentBoard.squares[x][y].stone != Stone.nothing) {
          _currentBoard.squares[x][y].state = SquareState.canNotPut;
          continue;
        }
        var putPoint = _canCheckPutSquare(stone: stone, x: x, y: y);
        if (putPoint.count > 0) {
          _currentBoard.squares[x][y].state = SquareState.canPut;
          _currentBoard._canPutPoints.add(putPoint);
        } else {
          _currentBoard.squares[x][y].state = SquareState.canNotPut;
        }
      }
    }
    var tempList = _currentBoard.squares.expand((e) => e).toList();
    _currentBoard._countBlack =
        tempList.where((e) => e.stone == Stone.black).length;
    _currentBoard._countWhite =
        tempList.where((e) => e.stone == Stone.white).length;
    var countNothing = tempList.where((e) => e.stone == Stone.nothing).length;
    if (countNothing == 0) {
      if (_currentBoard._countBlack == _currentBoard._countWhite) {
        _currentBoard._boardState = BoardState.draw;
      } else if (_currentBoard._countBlack > _currentBoard._countWhite) {
        _currentBoard._boardState = BoardState.winBlack;
      } else {
        _currentBoard._boardState = BoardState.winWhite;
      }
      return;
    }
    _currentBoard._boardState = BoardState.pending;
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
      if (_currentBoard.squares[x][y].stone == Stone.nothing) {
        return;
      }
      if (isFirst) {
        // 最初がないか、同じ色だと置けない
        if (_currentBoard.squares[x][y].stone == stone) {
          return;
        }
        isFirst = false;
        continue;
      }
      // 最初以外で同じ色だと置ける
      if (_currentBoard.squares[x][y].stone == stone) {
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
    if (x < 0 || x >= Board.boardWidth) {
      return true;
    }
    if (y < 0 || y >= Board.boardHeight) {
      return true;
    }
    return false;
  }
}
