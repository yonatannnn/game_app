import 'package:flutter/material.dart';
import 'package:game_app/widgets/gameTrial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class SinglePlayerOfflineGameScreen extends StatefulWidget {
  @override
  _SinglePlayerOfflineGameScreenState createState() =>
      _SinglePlayerOfflineGameScreenState();
}

class _SinglePlayerOfflineGameScreenState
    extends State<SinglePlayerOfflineGameScreen> {
  late String targetNumber;
  late String un;
  List<String> trials = [];
  final TextEditingController _guessController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isGuessInputVisible = false;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  void _loadGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    targetNumber = prefs.getString('targetNumber') ?? _generateTargetNumber();
    un = prefs.getString('username') ?? '';
    List<String>? savedTrials = prefs.getStringList('trials');
    if (savedTrials != null) {
      setState(() {
        trials = savedTrials;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Single Player Offline Game',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt_rounded),
            onPressed: () {
              _restartGame();
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: trials.length,
              itemBuilder: (context, index) {
                String trialNumber = trials[trials.length - 1 - index];
                int correctNumbers =
                    _calculateCorrectNumbers(trialNumber, targetNumber);
                int correctlyPlacedNumbers =
                    _calculateCorrectlyPlacedNumbers(trialNumber, targetNumber);

                return GameTrial(
                  trialNumber: '${un}_${trialNumber}',
                  index: index,
                  correctNumbers: correctNumbers,
                  correctlyPlacedNumbers: correctlyPlacedNumbers,
                );
              },
            ),
          ),
          Visibility(
            visible: _isGuessInputVisible,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _guessController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Enter 5-digit Guess',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _submitGuess(context, _guessController.text);
                      FocusScope.of(context).unfocus();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 12.0),
                    ),
                    child: Text('Submit Guess'),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isGuessInputVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isGuessInputVisible = !_isGuessInputVisible;
              });
            },
          ),
        ],
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

  void _submitGuess(BuildContext context, String guess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String targetNumber =
        prefs.getString('targetNumber') ?? _generateTargetNumber();

    if (guess.length != 5 || int.tryParse(guess) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 5-digit number!')),
      );
      return;
    }

    String formattedTrial = '$guess';

    setState(() {
      trials.add(formattedTrial);
      _guessController.clear();
    });

    await prefs.setStringList('trials', trials);

    int num1 = _calculateCorrectNumbers(guess, targetNumber);
    int num2 = _calculateCorrectlyPlacedNumbers(guess, targetNumber);

    print('num1 = $num1 num2 = $num2');
    bool endGame = checkEndGame(num1, num2);

    if (endGame) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Congratulations! You guessed the number!')),
      );
    }
  }

  void _restartGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      targetNumber = _generateTargetNumber();
      trials.clear();
      _guessController.clear();
    });

    await prefs.remove('trials');
    await prefs.setString('targetNumber', targetNumber);
  }

  String _generateTargetNumber() {
    Random random = Random();
    Set<int> digits = {};

    while (digits.length < 5) {
      digits.add(random.nextInt(10));
    }

    String targetNumber = digits.join('');

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('targetNumber', targetNumber);
    });

    return targetNumber;
  }

  bool checkEndGame(int num1, int num2) {
    return (num1 == 5 && num2 == 5);
  }
}
