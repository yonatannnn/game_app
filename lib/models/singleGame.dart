import 'package:cloud_firestore/cloud_firestore.dart';

class SingleGame {
  String gameId;
  String targetNumber;
  List<String> trials = [];
  String status;

  SingleGame({
    required this.status,
    required this.gameId,
    required this.targetNumber,
    required this.trials,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'gameId': gameId,
      'targetNumber': targetNumber,
      'trials': trials,
    };
  }

  static SingleGame fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SingleGame(
      status: data['status'] ?? '',
      gameId: data['gameId'] ?? '',
      targetNumber: data['targetNumber'] ?? '',
      trials: List<String>.from(data['trials'] ?? []),
    );
  }
}
