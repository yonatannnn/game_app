import 'package:cloud_firestore/cloud_firestore.dart';

class CompetitionService {
  final CollectionReference competitionCollection =
      FirebaseFirestore.instance.collection('competition');

  Future<void> saveCompetitionData(String username, int trialsLength) async {
    DocumentReference competitionDoc = competitionCollection.doc(username);

    DocumentSnapshot doc = await competitionDoc.get();
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null || data['trials'] > trialsLength) {
      await competitionDoc.set(
        {'trials': trialsLength},
        SetOptions(merge: true),
      );
    }
  }

  Stream<List<Map<String, dynamic>>> getAllCompetitionData() {
    return competitionCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return {
          'username': doc.id,
          'trials': data?['trials'] ?? 1000000,
        };
      }).toList();
    });
  }

  Future<Map<String, dynamic>> getCompetitionData(String username) async {
    DocumentSnapshot competitionDoc =
        await competitionCollection.doc(username).get();

    if (competitionDoc.exists) {
      return competitionDoc.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }
}
