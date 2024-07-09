import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package for text styling

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            'About the Number Guessing Game',
            style: GoogleFonts.openSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            'Welcome to the Number Guessing Game, a challenging puzzle where you guess a secret 5-digit number. You receive two hints: the correct number and how many digits are correctly placed.',
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.0),
          _buildGameModeSection(
            title: 'Offline Games',
            description:
                'Practice the Number Guessing Game offline to improve your skills.',
          ),
          SizedBox(height: 8.0),
          _buildGameModeSection(
            title: 'Online Single Player',
            description:
                'Compete with others online by scoring points in the Number Guessing Game.',
          ),
          SizedBox(height: 8.0),
          _buildGameModeSection(
            title: 'Online Multiplayer',
            description:
                'Challenge a friend in real-time multiplayer matches of the Number Guessing Game.',
          ),
          SizedBox(height: 24.0),
          Text(
            'Contact the Developer',
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          GestureDetector(
            onTap: () {
              _launchTelegram();
            },
            child: Text(
              'Telegram @lijaleme',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeSection(
      {required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.0),
        Text(
          description,
          style: GoogleFonts.openSans(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Method to launch Telegram link
  void _launchTelegram() async {
    const url = 'https://t.me/lijaleme'; // Replace with your Telegram link
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Handle error as needed, e.g., show a dialog or log the error
    }
  }
}
