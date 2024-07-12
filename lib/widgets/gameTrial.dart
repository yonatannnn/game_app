import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameTrial extends StatelessWidget {
  final String trialNumber;
  final int index;
  final int correctNumbers;
  final int correctlyPlacedNumbers;

  GameTrial(
      {required this.trialNumber,
      required this.index,
      required this.correctNumbers,
      required this.correctlyPlacedNumbers,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('here are ${trialNumber} -');
    return FutureBuilder<String>(
      future: _getUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final username = snapshot.data!;

          final user = trialNumber.split('_')[0];
          final number = trialNumber.split('_')[1];
          final isCurrentUser = user == username;
          print('userrrr ${user}   username  $username');
          double halfWidth = MediaQuery.of(context).size.width / 2;

          return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                color: isCurrentUser ? Colors.blue : Colors.brown,
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var digit in number.split(''))
                        Text(
                          '$digit',
                          style: GoogleFonts.aBeeZee(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    color: Colors.black,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'correct numbers = ${correctNumbers}',
                          style: GoogleFonts.aBeeZee(color: Colors.white),
                        ),
                        Text(
                            'correctly placed numbers = ${correctlyPlacedNumbers}',
                            style: GoogleFonts.aBeeZee(color: Colors.white))
                      ],
                    ),
                  )
                ]),
              ));
        }
      },
    );
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }
}
