import 'package:english_learning_app/app/core/constants/firestore.dart';
import 'package:english_learning_app/app/data/models/topic_model.dart';
import 'package:english_learning_app/app/data/services/firestore_service.dart';

class TopicRepository {
  final FirestoreService _firestore;

  TopicRepository(this._firestore);

  /// Lấy tất cả topic của 1 user
  Future<List<TopicModel>> getAllTopics(String userId) async {
    final snapshot = await _firestore.getSubCollection([
      (FirestorePath.users.value, userId),
    ], FirestorePath.topics.value);

    return snapshot.docs.map((doc) => TopicModel.fromFirestore(doc)).toList();
  }

  /// Lấy 1 topic theo ID
  Future<TopicModel?> getTopicById(String userId, String topicId) async {
    final doc = await _firestore.getSubDocument(
      [(FirestorePath.users.value, userId)],
      FirestorePath.topics.value,
      topicId,
    );

    if (!doc.exists) return null;
    return TopicModel.fromFirestore(doc);
  }

  /// Thêm word mới
  Future<String> addTopic(
    String userId,
    String topicId,
    TopicModel topic,
  ) async {
    final ref = await _firestore.addSubDocument(
      [(FirestorePath.users.value, userId)],
      FirestorePath.topics.value,
      topic.toFirestore(),
    );
    return ref.id;
  }

  /// Update word
  Future<void> updateTopic(String userId, TopicModel topic) {
    return _firestore.updateSubDocument(
      [(FirestorePath.users.value, userId)],
      FirestorePath.topics.value,
      topic.id,
      topic.toFirestore(),
    );
  }

  // /// Xóa word
  Future<void> deleteTopic(String userId, String topicId) {
    return _firestore.deleteSubDocument(
      [(FirestorePath.users.value, userId)],
      FirestorePath.topics.value,
      topicId,
    );
  }

  /// Lắng nghe real-time tất cả words trong 1 topic
  Stream<List<TopicModel>> streamTopics(String userId) {
    return _firestore
        .streamSubCollection([
          (FirestorePath.users.value, userId),
        ], FirestorePath.topics.value)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TopicModel.fromFirestore(doc))
              .toList(),
        );
  }

  // /// Lắng nghe real-time 1 word cụ thể
  Stream<TopicModel?> streamWordById(String userId, String topicId) {
    return _firestore
        .streamSubDocument(
          [(FirestorePath.users.value, userId)],
          FirestorePath.topics.value,
          topicId,
        )
        .map((doc) => doc.exists ? TopicModel.fromFirestore(doc) : null);
  }
}
