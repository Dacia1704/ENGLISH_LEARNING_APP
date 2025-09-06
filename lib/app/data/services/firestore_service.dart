import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._privateConstructor();

  static final FirestoreService instance =
      FirestoreService._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =============================
  // 📌 Collection (level 1)
  // =============================

  /// Lấy document theo ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collectionPath,
    String docId,
  ) {
    return _db.collection(collectionPath).doc(docId).get();
  }

  /// Lấy tất cả documents trong collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collectionPath,
  ) {
    return _db.collection(collectionPath).get();
  }

  /// Thêm mới document (Firestore tự sinh ID)
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).add(data);
  }

  /// Tạo/ghi đè document theo ID
  Future<void> setDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).doc(docId).set(data);
  }

  /// Update một phần dữ liệu
  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).doc(docId).update(data);
  }

  /// Xóa document
  Future<void> deleteDocument(String collectionPath, String docId) {
    return _db.collection(collectionPath).doc(docId).delete();
  }

  /// Lắng nghe thay đổi document (real-time)
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collectionPath,
    String docId,
  ) {
    return _db.collection(collectionPath).doc(docId).snapshots();
  }

  /// Lắng nghe thay đổi collection (real-time)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath,
  ) {
    return _db.collection(collectionPath).snapshots();
  }

  // =============================
  // 📌 Subcollection (level 2+)
  // =============================

  /// Helper: xây dựng reference đến subcollection từ danh sách cha
  CollectionReference<Map<String, dynamic>> _buildSubCollectionRef(
    List<(String, String)> parents, // List<Record<collection, docId>>
    String subCollection,
  ) {
    // Bắt đầu từ collection cha đầu tiên
    CollectionReference<Map<String, dynamic>> ref = _db.collection(
      parents.first.$1,
    );

    // Lấy document đầu tiên
    DocumentReference<Map<String, dynamic>>? docRef = ref.doc(parents.first.$2);

    // Duyệt tiếp các cấp cha còn lại
    for (int i = 1; i < parents.length; i++) {
      docRef = docRef!.collection(parents[i].$1).doc(parents[i].$2);
    }

    // Trả về reference của subcollection cuối
    return docRef!.collection(subCollection);
  }

  /// Lấy tất cả documents trong subcollection
  Future<QuerySnapshot<Map<String, dynamic>>> getSubCollection(
    List<(String, String)> parents,
    String subCollection,
  ) {
    return _buildSubCollectionRef(parents, subCollection).get();
  }

  /// Lấy 1 document trong subcollection
  Future<DocumentSnapshot<Map<String, dynamic>>> getSubDocument(
    List<(String, String)> parents,
    String subCollection,
    String subDocId,
  ) {
    return _buildSubCollectionRef(parents, subCollection).doc(subDocId).get();
  }

  /// Thêm document mới vào subcollection
  Future<DocumentReference<Map<String, dynamic>>> addSubDocument(
    List<(String, String)> parents,
    String subCollection,
    Map<String, dynamic> data,
  ) {
    return _buildSubCollectionRef(parents, subCollection).add(data);
  }

  /// Tạo/ghi đè 1 document trong subcollection
  Future<void> setSubDocument(
    List<(String, String)> parents,
    String subCollection,
    String subDocId,
    Map<String, dynamic> data,
  ) {
    return _buildSubCollectionRef(
      parents,
      subCollection,
    ).doc(subDocId).set(data);
  }

  /// Update document trong subcollection
  Future<void> updateSubDocument(
    List<(String, String)> parents,
    String subCollection,
    String subDocId,
    Map<String, dynamic> data,
  ) {
    return _buildSubCollectionRef(
      parents,
      subCollection,
    ).doc(subDocId).update(data);
  }

  /// Xóa document trong subcollection
  Future<void> deleteSubDocument(
    List<(String, String)> parents,
    String subCollection,
    String subDocId,
  ) {
    return _buildSubCollectionRef(
      parents,
      subCollection,
    ).doc(subDocId).delete();
  }

  /// Stream subcollection (real-time)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSubCollection(
    List<(String, String)> parents,
    String subCollection,
  ) {
    return _buildSubCollectionRef(parents, subCollection).snapshots();
  }

  /// Stream 1 document trong subcollection (real-time)
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamSubDocument(
    List<(String, String)> parents,
    String subCollection,
    String subDocId,
  ) {
    return _buildSubCollectionRef(
      parents,
      subCollection,
    ).doc(subDocId).snapshots();
  }
}
