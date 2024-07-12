import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  String gameId;
  String turn;
  String targetNumber1;
  String targetNumber2;
  List<String> trials = [];
  String winner;
  String loser;
  List<String> chat = [];

  Game(
      {required this.gameId,
      required this.turn,
      required this.targetNumber1,
      required this.targetNumber2,
      required this.trials,
      required this.winner,
      required this.loser,
      required this.chat});

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'turn': turn,
      'targetNumber1': targetNumber1,
      'targetNumber2': targetNumber2,
      'trials': trials,
      'winner': winner,
      'loser': loser,
      'chat': chat
    };
  }

  static Game fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Game(
        gameId: data['gameId'] ?? '',
        turn: data['turn'] ?? '',
        targetNumber1: data['targetNumber1'] ?? '',
        targetNumber2: data['targetNumber2'] ?? '',
        trials: List<String>.from(data['trials'] ?? []),
        winner: data['winner'] ?? '',
        loser: data['loser'] ?? '',
        chat: List<String>.from(data['chat'] ?? []));
  }
}
