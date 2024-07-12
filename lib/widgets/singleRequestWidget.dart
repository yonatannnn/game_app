import 'package:flutter/material.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/models/requestModel.dart';
import 'package:game_app/screens/gameScreen.dart';
import 'package:game_app/services/requestService.dart';
import 'package:game_app/services/gameService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class SingleRequestWidget extends StatelessWidget {
  final RequestModel request;
  final bool isSender;
  final RequestService _requestService = RequestService();
  final GameService _gameService = GameService();
  Game? _createdGame;

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
    } else if (request.status == 'Ended') {
      statusColor = Colors.amber;
      statusText = 'Ended';
    } else {
      statusColor = Colors.grey;
      statusText = 'Unknown status';
    }

    return GestureDetector(
      onTap: () async {
        if (isSender &&
            (request.status == 'Accepted' || request.status == 'Ended')) {
          Game? fetchedGame = await _fetchGameFromBackend();
          if (fetchedGame != null && fetchedGame.targetNumber2 == '-') {
            await _promptAndHandleTargetNumber(context, fetchedGame);
          } else if (fetchedGame != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(game: fetchedGame, requestSender: request.senderId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No game found for the request')),
            );
          }
        } else if (request.status == 'Accepted' || request.status == 'Ended') {
          Game? fetchedGame = await _fetchGameFromBackend();
          if (fetchedGame != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(game: fetchedGame , requestSender: request.senderId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No game found for the request')),
            );
          }
        } else if (request.status == '-' && isSender) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Wait until the opponent accepts the request')),
          );
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
    TextEditingController _numberController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter a 5-digit Number'),
          content: TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            maxLength: 5,
            decoration: InputDecoration(
              hintText: 'They must be unique!',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                String inputNumber = _numberController.text.trim();
                if (inputNumber.length == 5 &&
                    int.tryParse(inputNumber) != null &&
                    _checkUniqueDigits(inputNumber)) {
                  try {
                    await _requestService.updateRequestStatus(
                        request.id, 'Accepted');
                    String format = '${request.receiverId}_${inputNumber}';
                    _createdGame = await _createGame(format);
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                            game: _createdGame!,
                            requestSender: request.senderId),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error accepting request: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Please enter a valid 5-digit number with unique digits')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptAndHandleTargetNumber(
      BuildContext context, Game fetchedGame) async {
    TextEditingController _numberController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter a 5-digit Number'),
          content: TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            maxLength: 5,
            decoration: InputDecoration(
              hintText: 'They must be unipue',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () async {
                String inputNumber = _numberController.text.trim();
                if (inputNumber.length == 5 &&
                    int.tryParse(inputNumber) != null &&
                    _checkUniqueDigits(inputNumber)) {
                  try {
                    fetchedGame.targetNumber2 =
                        '${request.senderId}_${inputNumber}';
                    await _gameService.saveGame(fetchedGame);
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(
                            game: fetchedGame, requestSender: request.senderId),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating game: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Please enter a valid 5-digit number with unique digits')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool _checkUniqueDigits(String number) {
    List<String> digits = number.split('');

    Set<String> uniqueDigits = digits.toSet();
    return uniqueDigits.length == 5;
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

  Future<Game> _createGame(String inputNumber) async {
    String gameId = '${request.id}-${request.requestNumber}';

    Game game = Game(
      gameId: gameId,
      turn: request.senderId,
      targetNumber1: inputNumber,
      targetNumber2: '-',
      trials: [],
      winner: '-',
      loser: '-',
      chat: [],
    );

    await _gameService.saveGame(game);
    return game;
  }

  Future<Game?> _fetchGameFromBackend() async {
    try {
      String gameId = '${request.id}-${request.requestNumber}';
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
