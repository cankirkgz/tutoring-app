import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutoring/data/models/user_model.dart';

class UserRepository {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> updateUserProfile(UserModel user) async {
    await _users.doc(user.uid).update(user.toJson());
  }
}
