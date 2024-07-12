import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_app/models/gameModel.dart';

class GameService {
  final CollectionReference _gamesCollection =
      FirebaseFirestore.instance.collection('Games');

  Future<void> saveGame(Game game) async {
    await _gamesCollection.doc(game.gameId).set(game.toMap());
  }

  Future<void> deleteGame(String gameId) async {
    await _gamesCollection.doc(gameId).delete();
  }

  Future<void> updateTrialsAndTurn(
      String gameId, List<String> trials, String turn) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot gameDoc = await _gamesCollection.doc(gameId).get();
      if (!gameDoc.exists) {
        throw Exception('Game does not exist!');
      }

      transaction.update(_gamesCollection.doc(gameId), {
        'trials': trials,
        'turn': turn,
      });
    });
  }

  Future<void> updateChat(String gameId, List<String> chat) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot gameDoc = await _gamesCollection.doc(gameId).get();
      if (!gameDoc.exists) {
        throw Exception('Game does not exist!');
      }

      transaction.update(_gamesCollection.doc(gameId), {'chat': chat});
    });
  }

  Future<void> updateWinnerAndEndGame(
      String gameId, String winner, String loser) async {
    await _gamesCollection.doc(gameId).update({
      'winner': winner,
      'loser': loser,
    });
  }

  Stream<List<Game>> fetchGames() {
    return _gamesCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
      },
    );
  }

  Future<Game?> getGameById(String gameId) async {
    var gameDoc = await _gamesCollection.doc(gameId).get();

    if (gameDoc.exists) {
      return Game.fromFirestore(gameDoc);
    } else {
      return null;
    }
  }

  Stream<Game> streamGameById(String gameId) {
    return _gamesCollection.doc(gameId).snapshots().map((doc) {
      return Game.fromFirestore(doc);
    });
  }

  Future<void> updateTargetNumbersAndResetGame(
      String gameId, String targetNumber1, String targetNumber2) async {
    await _gamesCollection.doc(gameId).update({
      'targetNumber1': targetNumber1,
      'targetNumber2': targetNumber2,
      'trials': [],
      'winner': '-',
      'losser': '-',
      'status': 'Accepted'
    });
  }
}
