import 'package:cloud_firestore/cloud_firestore.dart';

class WordModel {
  final String id;
  final String topicId;
  final Map<String, String> translations;
  final double fluentRate;
  final int tryNumber;
  final int correctNumber;
  final bool needLearning;

  const WordModel({
    required this.id,
    required this.topicId,
    required this.translations,
    this.fluentRate = 0.0,
    this.tryNumber = 0,
    this.correctNumber = 0,
    this.needLearning = true,
  });

  factory WordModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return WordModel(
      id: doc.id,
      topicId: data['topicId'] ?? '',
      translations: Map<String, String>.from(data['translations'] ?? {}),
      fluentRate: (data['fluentRate'] ?? 0).toDouble(),
      tryNumber: data['tryNumber'] ?? 0,
      correctNumber: data['correctNumber'] ?? 0,
      needLearning: data['needLearning'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topicId': topicId,
      'translations': translations,
      'fluentRate': fluentRate,
      'tryNumber': tryNumber,
      'correctNumber': correctNumber,
      'needLearning': needLearning,
    };
  }

  @override
  String toString() {
    return "WordModel: {id: $id, topicId: $topicId, translation: $translations, fluentRate: $fluentRate, tryNumber: $tryNumber, correctNumber: $correctNumber, needLearning: $needLearning}";
  }
}
