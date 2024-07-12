import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:game_app/models/userModel.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final String collectionName = 'Users';

  Future<void> saveUser(User user) async {
    try {
      final docRef = _firestore.collection(collectionName).doc(user.userName);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        throw Exception('Username already exists');
      } else {
        await docRef.set(user.toMap());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> findUserById(String id) async {
    String Id = id.toLowerCase();
    try {
      final docRef = _firestore.collection(collectionName).doc(Id);
      final response = await docRef.get();
      if (response.exists) {
        return User.fromMap(response.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('User not found');
    }
  }

  Stream<List<User>> fetchUsers() {
    return _firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
