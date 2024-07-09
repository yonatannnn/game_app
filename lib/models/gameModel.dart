import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  String gameId;
  String turn;
  String targetNumber;
  List<int> trials = [];
  String winner;
  String loser;

  Game({
    required this.gameId,
    required this.turn,
    required this.targetNumber,
    required this.trials,
    required this.winner,
    required this.loser,
  });

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'turn': turn,
      'targetNumber': targetNumber,
      'trials': trials,
      'winner': winner,
      'loser': loser,
    };
  }

  static Game fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Game(
      gameId: data['gameId'] ?? '',
      turn: data['turn'] ?? '',
      targetNumber: data['targetNumber'] ?? '',
      trials: List<int>.from(data['trials'] ?? []),
      winner: data['winner'] ?? '',
      loser: data['loser'] ?? '',
    );
  }

}
