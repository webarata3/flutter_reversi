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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5.0),
                color: Colors.black,
                child: Row(
                  children: [
                    const Text(
                      '黒',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        widget.player1.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                color: Colors.white,
                child: Row(
                  children: [
                    const Text(
                      '白',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        widget.player2.label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5.0),
                color: Colors.black,
                child: Row(
                  children: [
                    const Text(
                      '黒',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_board.countBlack}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                color: Colors.white,
                child: Row(
                  children: [
                    const Text(
                      '白',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_board.countWhite}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              for (var y = 0; y < Board.boardHeight; y++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var x = 0; x < Board.boardWidth; x++)
                      SquareContainer(
                          x: x, y: y, board: _board, callBack: _tapCallBack)
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

class SquareContainer extends StatefulWidget {
  final int x;
  final int y;
  final Board board;
  final void Function({required int x, required int y}) callBack;

  const SquareContainer(
      {Key? key,
      required this.x,
      required this.y,
      required this.board,
      required this.callBack})
      : super(key: key);
  @override
  State<SquareContainer> createState() => SquareState();
}

class SquareState extends State<SquareContainer> {
  Color _getColor() {
    var canPut = widget.board.canPut(x: widget.x, y: widget.y);
    if (canPut) return Colors.yellow;
    var isLastPoint = widget.board.isLastPoint(x: widget.x, y: widget.y);
    if (isLastPoint) return Colors.blue;
    var isLastChanged = widget.board.isLastChanged(x: widget.x, y: widget.y);
    if (isLastChanged) return Colors.orange;
    return Colors.white;
  }

  static const Map<Stone, String> _stoneMap = {
    Stone.black: '⚫',
    Stone.white: '⚪',
  };

  @override
  Widget build(BuildContext context) {
    var stone = widget.board.getStone(x: widget.x, y: widget.y);
    return InkWell(
      onTap: () {
        widget.callBack(x: widget.x, y: widget.y);
      },
      child: Container(
        alignment: Alignment.center,
        width: 45.0,
        height: 45.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: _getColor(),
        ),
        child: Text(
          SquareState._stoneMap[stone] ?? '',
          style: const TextStyle(fontSize: 35),
        ),
      ),
    );
  }
}
