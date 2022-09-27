import 'package:flutter/material.dart';
import 'main_view.dart';
import '../reversi/operator.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartState();
}

class _StartState extends State<StartPage> {
  Player? _player1 = Player.human;
  Player? _player2 = Player.human;

  void change1(Player? player) {
    setState(() {
      _player1 = player;
    });
  }

  void change2(Player? player) {
    setState(() {
      _player2 = player;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ワイのリバーシ'),
      ),
      body: _getStartDisplay(),
    );
  }

  Column _getStartDisplay() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    "黒（先手）",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  PlayerRadioListTile(
                      groupValue: _player1, value: Player.human, f: change1),
                  PlayerRadioListTile(
                      groupValue: _player1, value: Player.cpu1, f: change1),
                  PlayerRadioListTile(
                      groupValue: _player1, value: Player.cpu2, f: change1),
                  PlayerRadioListTile(
                      groupValue: _player1, value: Player.cpu3, f: change1),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "白（後手）",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  PlayerRadioListTile(
                      groupValue: _player2, value: Player.human, f: change2),
                  PlayerRadioListTile(
                      groupValue: _player2, value: Player.cpu1, f: change2),
                  PlayerRadioListTile(
                      groupValue: _player2, value: Player.cpu2, f: change2),
                  PlayerRadioListTile(
                      groupValue: _player2, value: Player.cpu3, f: change2),
                ],
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(
                  player1: _player1!,
                  player2: _player2!,
                ),
              ),
            );
          },
          child: const Text('対局開始'),
        ),
      ],
    );
  }
}

class PlayerRadioListTile extends RadioListTile<Player> {
  PlayerRadioListTile(
      {Key? key,
      required Player? groupValue,
      required Player value,
      required void Function(Player? player) f})
      : super(
          key: key,
          value: value,
          groupValue: groupValue,
          title: Text(value.label),
          onChanged: (Player? player) {
            f(player);
          },
        );
}
