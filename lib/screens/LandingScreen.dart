import 'package:flutter/material.dart';
import 'package:game_app/models/singleGame.dart';
import 'package:game_app/screens/SingleGameScreen.dart';
import 'package:game_app/screens/homeScreen.dart';
import 'package:game_app/screens/offlineSinglePlayer.dart';
import 'package:game_app/services/singleGame.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class Landingscreen extends StatelessWidget {
  const Landingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _gameService = SingleGameService();

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
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SinglePlayerOfflineGameScreen()),
                    );
                  },
                  child: Text('Single Player Offline'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String username =
                          prefs.getString('username') ?? 'unknown_user';

                      SingleGame? existingGame =
                          await _gameService.getGameById(username);

                      if (existingGame != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SinglePlayerGameScreen(game: existingGame),
                          ),
                        );
                      } else {
                        String targetNumber = _generateTargetNumber();
                        String gameId = '${username}';

                        SingleGame game = SingleGame(
                          status: '-',
                          gameId: gameId,
                          targetNumber: targetNumber,
                          trials: [],
                        );

                        await _gameService.saveGame(game);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SinglePlayerGameScreen(game: game),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error starting game: $e')),
                      );
                    }
                  },
                  child: Text('Single Player Online'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('Multi Player'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
