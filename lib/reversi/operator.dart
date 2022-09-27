import 'board.dart';
import 'dart:io';
import 'dart:math';

enum Player {
  human(label: '人間'),
  cpu1(label: 'CPU1'),
  cpu2(label: 'CPU2'),
  cpu3(label: 'CPU3');

  final String label;

  const Player({required this.label});
}

abstract class Operator {
  Point next(Board board);

  bool isAuto();
}

class ConsoleHumanPlayer implements Operator {
  @override
  Point next(Board board) {
    var x = inputInt('x> ');
    var y = inputInt('y> ');
    return Point(x: x, y: y);
  }

  @override
  bool isAuto() {
    return false;
  }

  int inputInt(String message) {
    while (true) {
      stdout.write(message);
      var xStr = stdin.readLineSync();
      if (xStr == null) {
        continue;
      }
      var xTemp = int.tryParse(xStr);
      if (xTemp == null) {
        continue;
      }
      return xTemp;
    }
  }
}

class CpuRandom implements Operator {
  @override
  bool isAuto() {
    return true;
  }

  @override
  Point next(Board board) {
    var random = Random();
    var list = board.canPutPoints;
    var index = random.nextInt(list.length);

    var point = list[index].point;
    return Point(x: point.x, y: point.y);
  }
}

class CpuLittle implements Operator {
  @override
  bool isAuto() {
    return true;
  }

  @override
  Point next(Board board) {
    var list = board.canPutPoints;

    var putPointMap = <int, List<PutPoint>>{};
    var minCount = 65; // 64マスしかない
    for (var i = 0; i < list.length; i++) {
      if (minCount > list[i].count) {
        minCount = list[i].count;
      }
      var tempList = putPointMap.putIfAbsent(list[i].count, () => <PutPoint>[]);
      tempList.add(list[i]);
      putPointMap[list[i].count] = tempList;
    }
    var putPoints = putPointMap[minCount]!;
    var random = Random();
    var index = random.nextInt(putPoints.length);
    return Point(x: putPoints[index].point.x, y: putPoints[index].point.y);
  }
}

class CpuLittleToBig implements Operator {
  @override
  bool isAuto() {
    return true;
  }

  @override
  Point next(Board board) {
    var list = board.canPutPoints;

    var putPointMap = <int, List<PutPoint>>{};
    var minCount = 65; // 64マスしかない
    var maxCount = 0;

    var count = board.countBlack + board.countWhite;
    for (var i = 0; i < list.length; i++) {
      if (count >= 54) {
        if (maxCount < list[i].count) {
          maxCount = list[i].count;
        }
      } else {
        if (minCount > list[i].count) {
          minCount = list[i].count;
        }
      }
      var tempList = putPointMap.putIfAbsent(list[i].count, () => <PutPoint>[]);
      tempList.add(list[i]);
      putPointMap[list[i].count] = tempList;
    }
    var putPoints = putPointMap[count >= 54 ? maxCount : minCount]!;
    var random = Random();
    var index = random.nextInt(putPoints.length);
    return Point(x: putPoints[index].point.x, y: putPoints[index].point.y);
  }
}
