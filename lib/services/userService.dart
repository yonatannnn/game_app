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
    try {
      final docRef = _firestore.collection(collectionName).doc(id);
      final response = await docRef.get();
      if (response.exists) {
        return User.fromMap(response.data() as Map<String, dynamic>);
      } else {
        throw Exception('usernot Found');
      }
    } catch (e) {
      throw Exception('${e.toString()}');
    }
  }
}
