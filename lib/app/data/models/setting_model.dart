class SettingModel {
  final String defaultLanguage;
  final List<String> learningLanguages;
  final int quizInterval;
  final int quizAnswerTime;

  const SettingModel({
    this.defaultLanguage = 'Vietnamese',
    this.learningLanguages = const ['English'],
    this.quizInterval = 30 * 60,
    this.quizAnswerTime = 10,
  });

  /// Tạo từ Map (không phải DocumentSnapshot)
  factory SettingModel.fromMap(Map<String, dynamic> data) {
    return SettingModel(
      defaultLanguage: data['defaultLanguage'] ?? 'vi_VI',
      learningLanguages: List<String>.from(
        data['learningLanguages'] ?? ['en_US'],
      ),
      quizInterval: data['quizInterval'] ?? 30 * 60,
      quizAnswerTime: data['quizAnswerTime'] ?? 10,
    );
  }

  factory SettingModel.defaultSetting() => const SettingModel();

  Map<String, dynamic> toFirestore() {
    return {
      'defaultLanguage': defaultLanguage,
      'learningLanguages': learningLanguages,
      'quizInterval': quizInterval,
      'quizAnswerTime': quizAnswerTime,
    };
  }

  @override
  String toString() {
    return "SettingModel:{defaultLanguge: $defaultLanguage, learningLanguage: $learningLanguages, quizInterval: $quizInterval, quizAnswerTime: $quizAnswerTime}";
  }
}
