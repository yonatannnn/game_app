import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_app/models/gameModel.dart';
import 'package:game_app/models/singleGame.dart';

class SingleGameService {
  final CollectionReference _gamesCollection =
      FirebaseFirestore.instance.collection('SingleGames');

  Future<void> saveGame(SingleGame game) async {
    await _gamesCollection.doc(game.gameId).set(game.toMap());
  }

  Future<void> deleteGame(String gameId) async {
    await _gamesCollection.doc(gameId).delete();
  }

  Future<void> updateTrialsAndTurn(String gameId, List<String> trials) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot gameDoc = await _gamesCollection.doc(gameId).get();
      if (!gameDoc.exists) {
        throw Exception('Game does not exist!');
      }

      transaction.update(_gamesCollection.doc(gameId), {
        'trials': trials,
      });
    });
  }

  Future<void> endGame(String gameId, List<String> trials) async {
    print('Called');
    await _gamesCollection.doc(gameId).update({
      'trials': trials,
      'status': 'Ended',
    });
  }

  Stream<List<SingleGame>> fetchGames() {
    return _gamesCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => SingleGame.fromFirestore(doc))
            .toList();
      },
    );
  }

  Future<void> restart(String gameId, String targetNumber) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot gameDoc = await _gamesCollection.doc(gameId).get();
      if (!gameDoc.exists) {
        throw Exception('Game does not exist!');
      }

      transaction.update(_gamesCollection.doc(gameId), {
        'trials': [],
        'status': '-',
        'gameId': gameId,
        'targetNumber': targetNumber
      });
    });
  }

  Future<SingleGame?> getGameById(String gameId) async {
    var gameDoc = await _gamesCollection.doc(gameId).get();

    if (gameDoc.exists) {
      return SingleGame.fromFirestore(gameDoc);
    } else {
      return null;
    }
  }

  Stream<SingleGame> streamGameById(String gameId) {
    return _gamesCollection.doc(gameId).snapshots().map((doc) {
      return SingleGame.fromFirestore(doc);
    });
  }
}
