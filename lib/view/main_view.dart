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

  Text _getNext() {
    return switch (_board.boardState) {
      BoardState.pending =>
        _board.nextStone == Stone.black ? const Text('次 ⚫') : const Text('次 ⚪'),
      BoardState.winBlack => const Text('⚫の勝ち'),
      BoardState.winWhite => const Text('⚪の勝ち'),
      BoardState.draw => const Text('引き分け'),
    };
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => pointing());
    return Scaffold(
      appBar: AppBar(
        title: const Text('対局'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  color: Colors.purple[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _getNext(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 32,
                                  child: Text('⚫'),
                                ),
                                Text('${_board.countBlack}'),
                              ],
                            ),
                            Text(widget.player1.label),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 32,
                                  child: Text('⚪'),
                                ),
                                Text('${_board.countWhite}'),
                              ],
                            ),
                            Text(widget.player2.label),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
              setState(() => _board.restart());
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
    return const Color.fromARGB(255, 50, 158, 10);
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
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
