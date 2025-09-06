import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  final String id;
  final String name;
  final String? description;

  TopicModel({required this.id, required this.name, this.description});

  // Chuyển từ DocumentSnapshot Firestore -> TopicModel
  factory TopicModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TopicModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
    );
  }

  // Chuyển từ TopicModel -> Map để lưu Firestore
  Map<String, dynamic> toFirestore() {
    return {'name': name, 'description': description};
  }

  @override
  String toString() {
    return "TopicModel: {id: $id, name: $name, description: $description}";
  }
}
