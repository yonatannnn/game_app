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

  Future<void> updateTrials(String gameId, List<int> trials) async {
    await _gamesCollection.doc(gameId).update({'trials': trials});
  }

  Stream<List<Game>> fetchGames() {
    return _gamesCollection.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
      },
    );
  }

  Future<Game?> getGameById(String gameId) async {
    var gameDoc =
        await FirebaseFirestore.instance.collection('Games').doc(gameId).get();

    if (gameDoc.exists) {
      return Game.fromFirestore(gameDoc);
    } else {
      return null;
    }
  }

}
