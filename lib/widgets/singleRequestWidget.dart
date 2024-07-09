import 'package:flutter/material.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/models/requestModel.dart';
import 'package:game_app/screens/gameScreen.dart';
import 'package:game_app/services/requestService.dart';
import 'package:game_app/services/gameService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class SingleRequestWidget extends StatelessWidget {
  final RequestModel request;
  final bool isSender;
  final RequestService _requestService = RequestService();
  final GameService _gameService = GameService();
  Game? _createdGame; // Store the created game

  SingleRequestWidget({required this.isSender, required this.request});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if (request.status == '-') {
      statusColor = Colors.orange;
      statusText = 'Response not given';
    } else if (request.status == 'Accepted') {
      statusColor = Colors.green;
      statusText = 'Accepted';
    } else if (request.status == 'Declined') {
      statusColor = Colors.red;
      statusText = 'Declined';
    } else {
      statusColor = Colors.grey;
      statusText = 'Unknown status';
    }

    return GestureDetector(
      onTap: () async {
        if (request.status == 'Accepted') {
          Game? fetchedGame = await _fetchGameFromBackend();
          if (fetchedGame != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(game: fetchedGame),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No game found for the request')),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSender
                  ? 'To: ${request.receiverId}'
                  : 'From: ${request.senderId}',
              style: GoogleFonts.aBeeZee(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            if (!isSender && request.status == '-') ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildButton(context, 'Accept', Colors.green, () {
                    _handleAccept(context);
                  }),
                  _buildButton(context, 'Decline', Colors.red, () {
                    _handleDecline(context);
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAccept(BuildContext context) async {
    try {
      await _requestService.updateRequestStatus(request.id, 'Accepted');
      _createdGame = await _createGame();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request accepted and game created')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting request: $e')),
      );
    }
  }

  void _handleDecline(BuildContext context) async {
    try {
      await _requestService.updateRequestStatus(request.id, 'Declined');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request declined')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining request: $e')),
      );
    }
  }

  Future<Game> _createGame() async {
    String gameId = '${request.id}-${request.requestNumber}';
    String targetNumber = _generateTargetNumber();

    Game game = Game(
      gameId: gameId,
      turn: request.senderId,
      targetNumber: targetNumber,
      trials: [],
      winner: '-',
      loser: '-',
    );

    await _gameService.saveGame(game);
    return game;
  }

  Future<Game?> _fetchGameFromBackend() async {
    try {
      String gameId = '${request.id}-${request.requestNumber}';
      print(gameId);
      Game? game = await _gameService.getGameById(gameId);
      return game;
    } catch (e) {
      print('Error fetching game: $e');
      return null;
    }
  }

  String _generateTargetNumber() {
    Random random = Random();
    Set<int> digits = {};

    while (digits.length < 5) {
      digits.add(random.nextInt(10));
    }

    return digits.join('');
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
