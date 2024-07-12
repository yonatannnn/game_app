import 'dart:math';
import 'package:flutter/material.dart';
import 'package:game_app/models/singleGame.dart';
import 'package:game_app/services/singleGame.dart';
import 'package:game_app/services/competitionService.dart';
import 'package:game_app/widgets/gameTrial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SinglePlayerGameScreen extends StatelessWidget {
  final SingleGame game;
  final SingleGameService _gameService = SingleGameService();
  final CompetitionService _competitionService = CompetitionService();
  final TextEditingController _guessController = TextEditingController();

  SinglePlayerGameScreen({required this.game});

  @override
  Widget build(BuildContext context) {
    String targetNumber = game.targetNumber;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Single Player Game',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await _gameService.restart(
                    game.gameId, _generateTargetNumber());
              },
              icon: Icon(Icons.restart_alt_rounded))
        ],
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<SingleGame>(
        stream: _gameService.streamGameById(game.gameId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Error'));
          }

          SingleGame updatedGame = snapshot.data!;
          String targetNumber = updatedGame.targetNumber;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: updatedGame.trials.length,
                  itemBuilder: (context, index) {
                    String trialNumber = updatedGame
                        .trials[updatedGame.trials.length - 1 - index];
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
              if (updatedGame.status == '-') ...[
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
                    _submitGuess(context, _guessController.text, updatedGame);
                    FocusScope.of(context).unfocus();
                  },
                  child: Text('Submit Guess'),
                ),
              ],
              if (updatedGame.status != '-')
                Text(
                    'You have finished the game with ${updatedGame.trials.length} trials.',
                    style: GoogleFonts.aBeeZee(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white))
            ],
          );
        },
      ),
    );
  }

  int _calculateCorrectNumbers(String trialNumber, String targetNumber) {
    print('trialNumber = $trialNumber targetNumber = $targetNumber');
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
    print('trialNumber = $trialNumber targetNumber = $targetNumber');
    int correctlyPlacedNumbers = 0;

    for (int i = 0; i < 5; i++) {
      if (trialNumber[i] == targetNumber[i]) {
        correctlyPlacedNumbers++;
      }
    }

    return correctlyPlacedNumbers;
  }

  void _submitGuess(
      BuildContext context, String guess, SingleGame updatedGame) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUser = prefs.getString('username') ?? '';

    if (guess.length != 5 || int.tryParse(guess) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 5-digit number!')),
      );
      return;
    }

    String formattedTrial = '$currentUser' + '_' + '$guess';

    List<String> updatedTrials = List.from(updatedGame.trials);
    updatedTrials.add(formattedTrial);

    try {
      await _gameService.updateTrialsAndTurn(updatedGame.gameId, updatedTrials);
      _guessController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to submit guess. Please try again later.')),
      );
    }
    int num1 = _calculateCorrectNumbers(guess, updatedGame.targetNumber);
    int num2 =
        _calculateCorrectlyPlacedNumbers(guess, updatedGame.targetNumber);
    print('num1 = $num1 num2 = $num2');
    bool endGame = checkEndGame(num1, num2);

    if (endGame) {
      String ID = game.gameId;
      await _gameService.endGame(game.gameId, updatedTrials);
      await _competitionService.saveCompetitionData(
          game.gameId, updatedTrials.length);
    }
  }

  bool checkEndGame(int num1, int num2) {
    return (num1 == 5 && num2 == 5);
  }

  String _generateTargetNumber() {
    Random random = Random();
    Set<int> digits = {};

    while (digits.length < 5) {
      digits.add(random.nextInt(10));
    }

    return digits.join('');
  }
}
