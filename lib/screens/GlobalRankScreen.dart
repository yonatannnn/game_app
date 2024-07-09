import 'package:flutter/material.dart';
import 'package:game_app/services/competitionService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalRankScreen extends StatefulWidget {
  const GlobalRankScreen({super.key});

  @override
  _GlobalRankScreenState createState() => _GlobalRankScreenState();
}

class _GlobalRankScreenState extends State<GlobalRankScreen> {
  final CompetitionService _competitionService = CompetitionService();
  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Global Ranks',
          style: GoogleFonts.aBeeZee(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _competitionService.getAllCompetitionData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No competition data available.',
                style: GoogleFonts.aBeeZee(color: Colors.white),
              ),
            );
          }

          List<Map<String, dynamic>> competitionData = snapshot.data!;
          competitionData.sort((a, b) => a['trials'].compareTo(b['trials']));

          return ListView.builder(
            itemCount: competitionData.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = competitionData[index];
              String username = data['username'] ?? 'Unknown';
              int trials = data['trials'] ?? 1000000;

              return ListTile(
                title: Text(
                  username,
                  style: GoogleFonts.aBeeZee(
                    color: username == currentUsername
                        ? Colors.green
                        : Colors.white,
                  ),
                ),
                trailing: Text(
                  '$trials',
                  style: GoogleFonts.aBeeZee(
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
