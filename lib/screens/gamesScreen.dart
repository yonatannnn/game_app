import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/models/userModel.dart';
import 'package:game_app/services/gameService.dart';
import 'package:game_app/services/userService.dart';
import 'package:google_fonts/google_fonts.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Games',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showPassword = !showPassword;
              });
            },
            icon: Icon(
              Icons.do_not_touch,
              color: Colors.blue,
            ),
          )
        ],
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Game>>(
        stream: GameService().fetchGames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: GoogleFonts.aBeeZee(color: Colors.white)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('Games not found',
                    style: GoogleFonts.aBeeZee(color: Colors.white)));
          }

          List<Game> games = snapshot.data!;

          return ListView.separated(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${games[index].gameId}',
                      style: GoogleFonts.aBeeZee(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (showPassword)
                      Text(
                          'winner : ${games[index].winner}    loser : ${games[index].loser}',
                          style: GoogleFonts.aBeeZee(
                              fontSize: 13, color: Colors.white)),
                    if (showPassword)
                      Text('targetNumber1 : ${games[index].targetNumber1}',
                          style: GoogleFonts.aBeeZee(
                              fontSize: 13, color: Colors.white)),
                    if (showPassword)
                      Text('targetNumber2 : ${games[index].targetNumber2}',
                          style: GoogleFonts.aBeeZee(
                              fontSize: 13, color: Colors.white))
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(color: Colors.white),
            itemCount: games.length,
          );
        },
      ),
    );
  }
}
