import 'package:english_learning_app/app/core/constants/firestore.dart';
import 'package:english_learning_app/app/data/models/user_model.dart';
import 'package:english_learning_app/app/data/services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestore;
  UserRepository(this._firestore);

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.getDocument(FirestorePath.users.value, userId);
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(UserModel user) {
    return _firestore.updateDocument(
      FirestorePath.users.value,
      user.id,
      user.toFirestore(),
    );
  }
}
