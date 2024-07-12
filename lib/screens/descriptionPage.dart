import 'package:flutter/material.dart';

class DescriptionPage extends StatelessWidget {
  const DescriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Game Description',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Number Guessing Game',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to the Number Guessing Game! The objective is to guess a secret 5-digit number. You will receive two hints after each guess:',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '- Correct Numbers: The count of digits in your guess that are correct.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                '- Correctly Placed Numbers: From the correct numbers, how many are in the correct position.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Game Modes:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '1. Offline Single Player',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Practice the game in offline mode. Try to guess the secret number without any pressure of competing with others.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                '2. Online Single Player',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'In this mode, you will compete against other players globally. Your score is based on the number of guesses you make to find the secret number. After each game, your score is ranked globally. If you play again and score better, your previous score will be updated.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                '3. Two Players',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "end a game request to a friend by username. If your friend accepts, the game will start. You will guess the number chosen by your friend, and your friend will guess the number chosen by you. The first one to guess the other's number correctly wins!",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
