import 'package:flutter/material.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/screens/chatScreen.dart';
import 'package:game_app/services/gameService.dart';
import 'package:game_app/services/requestService.dart';
import 'package:game_app/widgets/gameTrial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  final Game game;
  String requestSender;

  GameScreen({required this.game, required this.requestSender});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  final TextEditingController _guessController = TextEditingController();
  int _currentIndex = 0;
  late String currentUser = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Center(child: CircularProgressIndicator());
    }

    List<String> targetNumber1s = widget.game.targetNumber1.split('_');
    List<String> targetNumber2s = widget.game.targetNumber2.split('_');

    if (targetNumber1s.length < 2 || targetNumber2s.length < 2) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your opponent hasn't provided the game number yet. Click the button below to check!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.aBeeZee(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                IconButton(
                  onPressed: () async {
                    Game? g =
                        await GameService().getGameById(widget.game.gameId);
                    if (g != null) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                              game: g, requestSender: widget.requestSender),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.refresh, color: Colors.white),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ),
      );
    }
    String realNumber;
    String realNumber2;
    if (targetNumber1s[0] == currentUser) {
      realNumber = targetNumber1s[1];
      realNumber2 = targetNumber2s[1];
    } else {
      realNumber = targetNumber2s[1];
      realNumber2 = targetNumber1s[1];
    }

    print('real number 1 $realNumber and real number 2 $realNumber2');

    List<String> player = widget.game.gameId.split("-");
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
        actions: [
          if (widget.requestSender == currentUser)
            IconButton(
              onPressed: () {
                _restartGame();
              },
              icon: Icon(Icons.restart_alt),
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<Game>(
        stream: _gameService.streamGameById(widget.game.gameId),
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

          if ((updatedGame.targetNumber1 == 'new_number' ||
                  updatedGame.targetNumber2 == 'new_number') &&
              currentUser == updatedGame.targetNumber1.split('_')[0]) {
            return Center(
              child: Text(
                'Waiting for the opponent...',
                style: GoogleFonts.aBeeZee(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            );
          } else if ((updatedGame.targetNumber1 == 'wait_number' ||
                  updatedGame.targetNumber2 == 'wait_number') &&
              currentUser != updatedGame.targetNumber1.split('_')[0]) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  String? newTargetNumber1 = updatedGame.targetNumber1;
                  String? newTargetNumber2 =
                      await _showInputDialog('Enter new number');

                  if (newTargetNumber1 != null && newTargetNumber2 != null) {
                    await _gameService.updateTargetNumbersAndResetGame(
                      widget.game.gameId,
                      newTargetNumber1,
                      '${currentUser}_${newTargetNumber2}',
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Game has been restarted.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Game restart cancelled.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Enter New Number',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          String currentTargetNumber = realNumber2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Current Turn: ${updatedGame.turn}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildGameView(
                        realNumber, players, realNumber, realNumber2),
                    ChatScreen(gameId: widget.game.gameId),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(String targetNumber, List<String> players,
      String realNumber, String realNumber2) {
    print('${realNumber} and ${realNumber2} and ${targetNumber}');
    return StreamBuilder<Game>(
      stream: _gameService.streamGameById(widget.game.gameId),
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

        if ((updatedGame.targetNumber1 == 'wait_number' ||
                updatedGame.targetNumber2 == 'wait_number') &&
            currentUser == updatedGame.targetNumber1.split('_')[0]) {
          return Center(
            child: Text(
              'Waiting for the opponent...',
              style: GoogleFonts.aBeeZee(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          );
        } else if ((updatedGame.targetNumber1 == 'wait_number' ||
                updatedGame.targetNumber2 == 'wait_number') &&
            currentUser != updatedGame.targetNumber1.split('_')[0]) {
          return Center(
            child: ElevatedButton(
              onPressed: () async {
                String? newTargetNumber1 = updatedGame.targetNumber1;
                String? newTargetNumber2 =
                    await _showInputDialog('Enter new number');

                if (newTargetNumber1 != null && newTargetNumber2 != null) {
                  await _gameService.updateTargetNumbersAndResetGame(
                    widget.game.gameId,
                    newTargetNumber1,
                    '${currentUser}_${newTargetNumber2}',
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Game has been restarted.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Game restart cancelled.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Enter New Number',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        String currentTargetNumber = realNumber2;
        String target1 = updatedGame.targetNumber1;
        String target2 = updatedGame.targetNumber2;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: updatedGame.trials.length,
                itemBuilder: (context, index) {
                  String trialNumber =
                      updatedGame.trials[updatedGame.trials.length - 1 - index];

                  if (trialNumber.split('_')[0] == currentUser) {
                    if (target1.split('_')[0] == currentUser) {
                      currentTargetNumber = target2.split('_')[1];
                    } else {
                      currentTargetNumber = target1.split('_')[1];
                    }
                  } else {
                    if (target2.split('_')[0] == currentUser) {
                      currentTargetNumber = target2.split('_')[1];
                    } else {
                      currentTargetNumber = target1.split('_')[1];
                    }
                  }
                  int correctNumbers = _calculateCorrectNumbers(
                      trialNumber.split('_')[1], currentTargetNumber);
                  int correctlyPlacedNumbers = _calculateCorrectlyPlacedNumbers(
                      trialNumber.split('_')[1], currentTargetNumber);

                  return GameTrial(
                    trialNumber: trialNumber,
                    index: index,
                    correctNumbers: correctNumbers,
                    correctlyPlacedNumbers: correctlyPlacedNumbers,
                  );
                },
              ),
            ),
            if (updatedGame.winner == '-')
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width * 0.5,
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 15),
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: () {
                            _submitGuess(context, _guessController.text,
                                players, updatedGame, currentTargetNumber);
                            FocusScope.of(context).unfocus();
                          },
                          child: Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (updatedGame.winner != '-')
              Text('The winner is ${updatedGame.winner}',
                  style: GoogleFonts.aBeeZee(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white)),
          ],
        );
      },
    );
  }

  int _calculateCorrectNumbers(String trialNumber, String targetNumber) {
    print('${trialNumber} - with - ${targetNumber}');
    int correctNumbers = 0;
    for (int i = 0; i < 5; i++) {
      if (targetNumber.contains(trialNumber[i])) {
        correctNumbers++;
      }
    }

    print('correct numbers are ${correctNumbers}');

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
    print('correctly placed numbers are ${correctlyPlacedNumbers}');
    return correctlyPlacedNumbers;
  }

  void _submitGuess(BuildContext context, String guess, List<String> players,
      Game updatedGame, String targetNumber) async {
    Game? g = await _gameService.getGameById(updatedGame.gameId);
    if (g?.targetNumber1 == '-' || g?.targetNumber2 == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wait for the opponent...')),
      );
      return;
    }

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
        SnackBar(content: Text('Enter 5 digit number!')),
      );
      return;
    }

    String formattedTrial = '$currentUser' + '_' + '$guess';

    List<String> updatedTrials = List.from(updatedGame.trials);
    updatedTrials.add(formattedTrial);

    String target1 = updatedGame.targetNumber1;
    String target2 = updatedGame.targetNumber2;

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

    print('Target number is ${targetNumber} and guess number is ${guess}');

    bool endGame = checkEndGame(_calculateCorrectNumbers(guess, targetNumber),
        _calculateCorrectlyPlacedNumbers(guess, targetNumber));
    print('end game = $endGame');

    if (endGame) {
      List<String> IDs = widget.game.gameId.split('-');
      IDs.removeLast();
      IDs.sort();
      String ID = IDs.join("-");
      String loser = currentUser == players[0] ? players[1] : players[0];
      await _gameService.updateWinnerAndEndGame(
          widget.game.gameId, currentUser, loser);
      await RequestService().updateRequestStatus(ID, 'Ended');
    }
  }

  bool checkEndGame(num1, num2) {
    return (num1 == 5 && num2 == 5);
  }

  Future<void> _restartGame() async {
    String? targetNumber1 = await _showInputDialog('Enter new target number 1');
    String? targetNumber2 = widget.game.targetNumber2 == '-'
        ? await _showInputDialog('Enter new target number 2')
        : widget.game.targetNumber2;

    if (targetNumber1 != null && targetNumber2 != null) {
      await _gameService.updateTargetNumbersAndResetGame(
        widget.game.gameId,
        '${currentUser}_${targetNumber1}',
        'wait_number',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wait for the other oponent!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game restart cancelled.')),
      );
    }
  }

  Future<String?> _showInputDialog(String title) async {
    TextEditingController _inputController = TextEditingController();
    String? errorMessage;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Enter 5-digit number',
                      errorText: errorMessage,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    onChanged: (value) {
                      if (value.length == 5) {
                        if (_hasUniqueDigits(value)) {
                          setState(() {
                            errorMessage = null;
                          });
                        } else {
                          setState(() {
                            errorMessage = 'Digits must be unique';
                          });
                        }
                      } else {
                        setState(() {
                          errorMessage = 'Number must be 5 digits';
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_inputController.text.length == 5 &&
                        _hasUniqueDigits(_inputController.text)) {
                      Navigator.of(context).pop(_inputController.text);
                    } else {
                      setState(() {
                        errorMessage = 'Number must be 5 unique digits';
                      });
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _hasUniqueDigits(String value) {
    return value.split('').toSet().length == value.length;
  }
}
