import 'package:english_learning_app/app/core/constants/firestore.dart';
import 'package:english_learning_app/app/core/redux/app_state.dart';
import 'package:english_learning_app/app/data/models/topic_model.dart';
import 'package:english_learning_app/app/data/models/word_model.dart';
import 'package:english_learning_app/app/data/repositories/topic_repository.dart';
import 'package:english_learning_app/app/data/repositories/word_repository.dart';
import 'package:english_learning_app/app/data/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  // Use a map to dynamically manage controllers for each language
  final Map<String, TextEditingController> _controllers = {};

  // State variables for topics and loading status
  List<TopicModel> _topics = [];
  TopicModel? _selectedTopic;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize controllers and fetch data only once
    if (!_isInitialized) {
      final state = StoreProvider.of<AppState>(context).state;
      if (state.user != null) {
        _initializeControllers(state);
        _fetchTopics(state.user!.id);
        _isInitialized = true;
      }
    }
  }

  /// Initializes TextEditingControllers based on the user's language settings.
  void _initializeControllers(AppState state) {
    final userSettings = state.user!.setting;

    _controllers[userSettings.defaultLanguage] = TextEditingController();
    for (final lang in userSettings.learningLanguages) {
      _controllers[lang] = TextEditingController();
    }
  }

  Future<void> _fetchTopics(String userId) async {
    try {
      final topics = await TopicRepository(
        FirestoreService.instance,
      ).getAllTopics(userId);
      setState(() {
        _topics = topics;
        // Optionally, pre-select the topic if there is only one
        if (_topics.isNotEmpty) {
          _selectedTopic = _topics.first;
        }
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "error_fetching_topics".tr());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveWord() async {
    final state = StoreProvider.of<AppState>(context, listen: false).state;
    final userSettings = state.user!.setting;

    if (_selectedTopic == null) {
      Fluttertoast.showToast(msg: "please_select_a_topic".tr());
      return;
    }

    final defaultLanguageText =
        _controllers[userSettings.defaultLanguage]?.text.trim() ?? '';
    if (defaultLanguageText.isEmpty) {
      Fluttertoast.showToast(
        msg: tr("please_fill_in", args: [userSettings.defaultLanguage]),
      );
      return;
    }

    final translations = <String, String>{};
    for (final lang in userSettings.learningLanguages) {
      final text = _controllers[lang]?.text.trim() ?? '';
      if (text.isNotEmpty) {
        translations[lang] = text;
      }
    }

    if (translations.isEmpty) {
      Fluttertoast.showToast(
        msg: "please_provide_at_least_one_translation".tr(),
      );
      return;
    }

    // print('Saving word to topic: ${_selectedTopic!.name}');
    // print('Default (${userSettings.defaultLanguage}): $defaultLanguageText');
    // print('Translations: $translations');

    try {
      final word = WordModel(
        id: FirebaseFirestore.instance
            .collection(FirestorePath.words.value)
            .doc()
            .id,
        topicId: _selectedTopic!.id,
        translations: {
          userSettings.defaultLanguage: defaultLanguageText,
          ...translations,
        },
      );
      await WordRepository(
        FirestoreService.instance,
      ).addWord(state.user!.id, _selectedTopic!.id, word);
    } catch (e) {
      Fluttertoast.showToast(msg: "Thêm từ không thành công");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    Fluttertoast.showToast(
      msg: tr("word_saved_successfully", args: [defaultLanguageText]),
    );
    _controllers.forEach((_, controller) => controller.clear());
    FocusScope.of(context).unfocus();
  }

  void _importFromFile() {
    Fluttertoast.showToast(msg: "feature_coming_soon".tr());
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if (state.user == null) {
          return Scaffold(
            appBar: AppBar(title: Text("add_new_word".tr())),
            body: Center(child: Text("user_not_found".tr())),
          );
        }

        final defaultLanguage = state.user!.setting.defaultLanguage;
        final learningLanguages = state.user!.setting.learningLanguages;

        return Scaffold(
          appBar: AppBar(title: Text("add_new_word".tr()), centerTitle: true),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "add_a_new_word".tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),

                      // Topic Selector Dropdown
                      DropdownButtonFormField<TopicModel>(
                        value: _selectedTopic,
                        onChanged: (TopicModel? newValue) {
                          setState(() {
                            _selectedTopic = newValue;
                          });
                        },
                        items: _topics.map((TopicModel topic) {
                          return DropdownMenuItem<TopicModel>(
                            value: topic,
                            child: Text(topic.name),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'select_topic'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null ? 'topic_is_required'.tr() : null,
                      ),
                      const SizedBox(height: 16),

                      // Default Language Input Field
                      TextField(
                        controller: _controllers[defaultLanguage],
                        decoration: InputDecoration(
                          labelText: defaultLanguage.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Learning Languages Input Fields
                      ...learningLanguages.map(
                        (lang) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: TextField(
                            controller: _controllers[lang],
                            decoration: InputDecoration(
                              labelText: lang.tr(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: _saveWord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'save_word'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Divider(height: 40, thickness: 1),

                      // Bulk Import Section
                      Text(
                        'bulk_import'.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _importFromFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text('import_from_file'.tr()),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
