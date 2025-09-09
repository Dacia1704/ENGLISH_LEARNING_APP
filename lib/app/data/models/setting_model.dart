class SettingModel {
  String defaultLanguage;
  List<String> learningLanguages;
  int quizInterval;
  int quizAnswerTime;
  bool quizEnable;

  SettingModel({
    this.defaultLanguage = 'Vietnamese',
    this.learningLanguages = const ['English'],
    this.quizInterval = 30 * 60,
    this.quizAnswerTime = 10,
    this.quizEnable = false,
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
      quizEnable: data["quizEnable"] ?? false,
    );
  }

  factory SettingModel.defaultSetting() => SettingModel();

  Map<String, dynamic> toFirestore() {
    return {
      'defaultLanguage': defaultLanguage,
      'learningLanguages': learningLanguages,
      'quizInterval': quizInterval,
      'quizAnswerTime': quizAnswerTime,
      'quizEnable': quizEnable,
    };
  }

  @override
  String toString() {
    return "SettingModel:{defaultLanguge: $defaultLanguage, learningLanguage: $learningLanguages, quizInterval: $quizInterval, quizAnswerTime: $quizAnswerTime. quizEnable: $quizEnable}";
  }

  SettingModel copy() {
    return SettingModel(
      defaultLanguage: defaultLanguage,
      learningLanguages: List<String>.from(learningLanguages),
      quizInterval: quizInterval,
      quizAnswerTime: quizAnswerTime,
      quizEnable: quizEnable,
    );
  }
}
