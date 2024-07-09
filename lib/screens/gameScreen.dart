import 'package:flutter/material.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/services/gameService.dart';
import 'package:game_app/services/requestService.dart';
import 'package:game_app/widgets/gameTrial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatelessWidget {
  final Game game;
  final GameService _gameService = GameService();
  final TextEditingController _guessController = TextEditingController();

  GameScreen({required this.game});

  @override
  Widget build(BuildContext context) {
    String realNumber = game.targetNumber;
    List<String> player = game.gameId.split("-");
    List<String> players = [player[0], player[1]];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<Game>(
        stream: _gameService.streamGameById(game.gameId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Game not found'));
          }

          Game updatedGame = snapshot.data!;
          String targetNumber = realNumber;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: updatedGame.trials.length,
                  itemBuilder: (context, index) {
                    String trialNumber = updatedGame.trials[index];
                    int correctNumbers = _calculateCorrectNumbers(
                        trialNumber.split('_')[1], targetNumber);
                    int correctlyPlacedNumbers =
                        _calculateCorrectlyPlacedNumbers(
                            trialNumber.split('_')[1], targetNumber);

                    return GameTrial(
                      trialNumber: trialNumber,
                      index: index,
                      correctNumbers: correctNumbers,
                      correctlyPlacedNumbers: correctlyPlacedNumbers,
                    );
                  },
                ),
              ),
              if (updatedGame.winner == '-') ...[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _guessController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Enter 5-digit Guess',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _submitGuess(
                        context, _guessController.text, players, updatedGame);
                  },
                  child: Text('Submit Guess'),
                ),
              ],
              if (updatedGame.winner != '-')
                Text('The winner is ${updatedGame.winner}',
                    style: GoogleFonts.aBeeZee(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white))
            ],
          );
        },
      ),
    );
  }

  int _calculateCorrectNumbers(String trialNumber, String targetNumber) {
    int correctNumbers = 0;
    for (int i = 0; i < 5; i++) {
      if (targetNumber.contains(trialNumber[i])) {
        correctNumbers++;
      }
    }

    return correctNumbers;
  }

  int _calculateCorrectlyPlacedNumbers(
      String trialNumber, String targetNumber) {
    int correctlyPlacedNumbers = 0;

    for (int i = 0; i < 5; i++) {
      if (trialNumber[i] == targetNumber[i]) {
        correctlyPlacedNumbers++;
      }
    }

    return correctlyPlacedNumbers;
  }

  void _submitGuess(BuildContext context, String guess, List<String> players,
      Game updatedGame) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUser = prefs.getString('username') ?? '';
    if (updatedGame.turn != currentUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('It is not your turn to guess!')),
      );
      return;
    }

    if (guess.length != 5 || int.tryParse(guess) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 5-digit number!')),
      );
      return;
    }

    String formattedTrial = '$currentUser' + '_' + '$guess';

    List<String> updatedTrials = List.from(updatedGame.trials);
    updatedTrials.add(formattedTrial);

    String nextTurn =
        (updatedGame.turn == players[0]) ? players[1] : players[0];

    try {
      await _gameService.updateTrialsAndTurn(
          updatedGame.gameId, updatedTrials, nextTurn);
      _guessController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to submit guess. Please try again later.')),
      );
    }

    bool endGame = checkEndGame(
        _calculateCorrectNumbers(guess, game.targetNumber),
        _calculateCorrectlyPlacedNumbers(guess, game.targetNumber));

    if (endGame) {
      List<String> IDs = game.gameId.split('-');
      IDs.removeLast();
      IDs.sort();
      String ID = IDs.join("-");
      String loser = currentUser == players[0] ? players[1] : players[0];
      await _gameService.updateWinnerAndEndGame(
          game.gameId, currentUser, loser);
      await RequestService().updateRequestStatus(ID, 'Ended');
    }
  }

  bool checkEndGame(num1, num2) {
    return (num1 == 5 && num2 == 5);
  }
}
