import 'package:flutter/material.dart';
import '../reversi/board.dart';
import '../reversi/operator.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  MainPage({Key? key, required this.player1, required this.player2})
      : super(key: key) {
    _operatorMap[Stone.black] = operatorMap[player1]!;
    _operatorMap[Stone.white] = operatorMap[player2]!;
  }

  final Player player1;
  final Player player2;

  final _operatorMap = <Stone, Operator>{};

  final operatorMap = {
    Player.human: ConsoleHumanPlayer(),
    Player.cpu1: CpuRandom(),
    Player.cpu2: CpuLittle(),
    Player.cpu3: CpuLittleToBig(),
  };

  @override
  State<MainPage> createState() => _MainState();
}

class _MainState extends State<MainPage> {
  final _board = Board();

  @override
  void initState() {
    super.initState();
  }

  void pointing() {
    if (_board.boardState == BoardState.pending) {
      // nullではない
      var operator = widget._operatorMap[_board.nextStone]!;

      if (operator.isAuto()) {
        Timer(const Duration(milliseconds: 500), () => _put(operator));
      }
    }
  }

  void _put(Operator operator) {
    var point = operator.next(_board);
    setState(() {
      _board.put(x: point.x, y: point.y);
    });
  }

  void _tapCallBack({required int x, required int y}) {
    var operator = widget._operatorMap[_board.nextStone]!;
    if (operator.isAuto()) {
      return;
    }
    var canPut = _board.canPutPoints
        .where((elm) => elm.point.x == x && elm.point.y == y)
        .isNotEmpty;
    if (canPut) {
      setState(() {
        _board.put(x: x, y: y);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => {pointing()});
    return Scaffold(
      appBar: AppBar(
        title: const Text('ワイのリバーシ'),
      ),
      body: Column(
        children: [
          Text(
            '黒（先行）: ${widget.player1.label}  白（後攻）: ${widget.player2.label}',
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            '黒: ${_board.countBlack}   白: ${_board.countWhite}',
            style: Theme.of(context).textTheme.headline6,
          ),
          Column(
            children: [
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 0, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 0, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 0, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 0, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 0, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 0, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 0, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 0, board: _board, callBack: _tapCallBack),
                ],
              ),
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 1, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 1, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 1, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 1, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 1, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 1, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 1, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 1, board: _board, callBack: _tapCallBack),
                ],
              ),
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 2, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 2, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 2, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 2, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 2, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 2, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 2, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 2, board: _board, callBack: _tapCallBack),
                ],
              ),
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 3, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 3, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 3, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 3, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 3, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 3, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 3, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 3, board: _board, callBack: _tapCallBack),
                ],
              ),
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 4, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 4, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 4, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 4, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 4, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 4, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 4, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 4, board: _board, callBack: _tapCallBack),
                ],
              ),
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 5, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 5, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 5, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 5, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 5, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 5, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 5, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 5, board: _board, callBack: _tapCallBack),
                ],
              ),
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 6, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 6, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 6, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 6, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 6, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 6, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 6, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 6, board: _board, callBack: _tapCallBack),
                ],
              ),
              Row(
                children: [
                  _SquareContainer(
                      x: 0, y: 7, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 1, y: 7, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 2, y: 7, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 3, y: 7, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 4, y: 7, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 5, y: 7, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 6, y: 7, board: _board, callBack: _tapCallBack),
                  _SquareContainer(
                      x: 7, y: 7, board: _board, callBack: _tapCallBack),
                ],
              ),
            ],
          ),
          ElevatedButton(
            child: const Text('再戦'),
            onPressed: () {
              setState(() => {_board.restart()});
            },
          ),
        ],
      ),
    );
  }
}

class _SquareContainer extends InkWell {
  final int x;
  final int y;
  final Board board;
  final void Function({required int x, required int y}) callBack;

  _SquareContainer(
      {required this.x,
      required this.y,
      required this.board,
      required this.callBack});

  var _text = '';

  @override
  Widget build(BuildContext context) {
    var stone = board.getStone(x: x, y: y);
    if (stone == Stone.black) {
      _text = '●';
    } else if (stone == Stone.white) {
      _text = '○';
    } else {
      _text = '';
    }
    var canPut = board.canPutPoints
        .where((e) => e.point.x == x && e.point.y == y)
        .isNotEmpty;
    var color = canPut
        ? Colors.yellow
        : (board.lastPoint?.x == x && board.lastPoint?.y == y
            ? Colors.blue
            : (board.lastChanged.where((e) => e.x == x && e.y == y).isNotEmpty
                ? Colors.orange
                : Colors.white));
    return InkWell(
      onTap: () {
        callBack(x: x, y: y);
      },
      child: Container(
        alignment: Alignment.center,
        width: 45.0,
        height: 45.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: color,
        ),
        child: Text(
          _text,
          style: const TextStyle(fontSize: 35),
        ),
      ),
    );
  }
}
