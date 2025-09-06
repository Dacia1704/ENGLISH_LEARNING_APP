import 'package:english_learning_app/app/core/constants/firestore.dart';
import 'package:english_learning_app/app/data/models/word_model.dart';
import 'package:english_learning_app/app/data/services/firestore_service.dart';

class WordRepository {
  final FirestoreService _firestore;

  WordRepository(this._firestore);

  /// Lấy tất cả word của 1 topic
  Future<List<WordModel>> getAllWords(String userId, String topicId) async {
    final snapshot = await _firestore.getSubCollection([
      (FirestorePath.users.value, userId),
      (FirestorePath.topics.value, topicId),
    ], FirestorePath.words.value);

    return snapshot.docs.map((doc) => WordModel.fromFirestore(doc)).toList();
  }

  /// Lấy 1 word theo ID
  Future<WordModel?> getWordById(
    String userId,
    String topicId,
    String wordId,
  ) async {
    final doc = await _firestore.getSubDocument(
      [
        (FirestorePath.users.value, userId),
        (FirestorePath.topics.value, topicId),
      ],
      FirestorePath.words.value,
      wordId,
    );

    if (!doc.exists) return null;
    return WordModel.fromFirestore(doc);
  }

  /// Thêm word mới
  Future<void> addWord(String userId, String topicId, WordModel word) async {
    await _firestore.addSubDocument(
      [
        (FirestorePath.users.value, userId),
        (FirestorePath.topics.value, topicId),
      ],
      FirestorePath.words.value,
      word.toFirestore(),
    );
    // return ref.id;
  }

  /// Update word
  Future<void> updateWord(String userId, String topicId, WordModel word) {
    return _firestore.updateSubDocument(
      [
        (FirestorePath.users.value, userId),
        (FirestorePath.topics.value, topicId),
      ],
      FirestorePath.words.value,
      word.id,
      word.toFirestore(),
    );
  }

  // /// Xóa word
  Future<void> deleteWord(String userId, String topicId, String wordId) {
    return _firestore.deleteSubDocument(
      [
        (FirestorePath.users.value, userId),
        (FirestorePath.topics.value, topicId),
      ],
      FirestorePath.words.value,
      wordId,
    );
  }

  /// Lắng nghe real-time tất cả words trong 1 topic
  Stream<List<WordModel>> streamWords(String userId, String topicId) {
    return _firestore
        .streamSubCollection([
          (FirestorePath.users.value, userId),
          (FirestorePath.topics.value, topicId),
        ], FirestorePath.words.value)
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => WordModel.fromFirestore(doc)).toList(),
        );
  }

  // /// Lắng nghe real-time 1 word cụ thể
  Stream<WordModel?> streamWordById(
    String userId,
    String topicId,
    String wordId,
  ) {
    return _firestore
        .streamSubDocument(
          [
            (FirestorePath.users.value, userId),
            (FirestorePath.topics.value, topicId),
          ],
          FirestorePath.words.value,
          wordId,
        )
        .map((doc) => doc.exists ? WordModel.fromFirestore(doc) : null);
  }
}
