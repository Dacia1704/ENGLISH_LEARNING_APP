enum Language {
  vietnamese(key: 'vi_VI', value: 'Việt Nam'),
  englishUS(key: 'en_US', value: 'English (US)'),
  chinese(key: 'zh_CN', value: '中国'),
  japanese(key: 'ja_JP', value: '日本語'),
  korean(key: 'ko_KR', value: '한국어');

  const Language({required this.key, required this.value});

  final String key;

  final String value;
}
