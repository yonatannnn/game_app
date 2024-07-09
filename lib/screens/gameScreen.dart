import 'package:flutter/material.dart';
import 'package:game_app/models/gameModel.dart';

class GameScreen extends StatelessWidget {
  final Game game;

  GameScreen({required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Game ID: ${game.gameId}'),
            Text('Turn: ${game.turn}'),
            Text('Target Number: ${game.targetNumber}'),
            Text('Winner: ${game.winner}'),
            Text('Loser: ${game.loser}'),
          ],
        ),
      ),
    );
  }
}
