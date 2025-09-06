import 'package:english_learning_app/app/core/redux/app_state.dart';
import 'package:english_learning_app/app/data/models/topic_model.dart';
import 'package:english_learning_app/app/data/models/user_model.dart';
import 'package:english_learning_app/app/data/models/word_model.dart';
import 'package:english_learning_app/app/data/repositories/topic_repository.dart';
import 'package:english_learning_app/app/data/repositories/word_repository.dart';
import 'package:english_learning_app/app/data/services/firestore_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  // Local state for the screen
  bool _isLoading = true;
  UserModel? _appUser;
  List<TopicModel> _topics = [];
  Map<String, List<WordModel>> _topicWords = {};

  // Repositories for data access
  final _topicRepo = TopicRepository(FirestoreService.instance);
  final _wordRepo = WordRepository(FirestoreService.instance);

  @override
  void initState() {
    super.initState();
    _fetchAndInitializeData();
  }

  Future<void> _fetchAndInitializeData() async {
    await _reloadData();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadData() async {
    final store = StoreProvider.of<AppState>(context, listen: false);
    _appUser = store.state.user;
    final userId = _appUser?.id;
    if (userId == null) return;
    print(1);

    setState(() => _isLoading = true);

    try {
      final topicCollection = await _topicRepo.getAllTopics(userId);
      final Map<String, List<WordModel>> topicWordCollection = {};

      for (var topic in topicCollection) {
        final wordCollection = await _wordRepo.getAllWords(userId, topic.id);
        topicWordCollection[topic.id] = wordCollection;
      }

      if (mounted) {
        setState(() {
          _topics = topicCollection;
          _topicWords = topicWordCollection;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to reload data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateAndReload() async {
    await context.push('/add');
    await _reloadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_appUser == null) {
      return Scaffold(
        body: Center(child: Text("no_user_data_try_restarting".tr())),
      );
    }

    return StoreConnector<AppState, UserModel?>(
      converter: (store) => store.state.user,
      builder: (context, userFromStore) {
        if (userFromStore == null) {
          return Scaffold(
            body: Center(child: Text("no_user_data_in_store".tr())),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text("app_title".tr()), centerTitle: true),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _navigateAndReload,
          //   backgroundColor: Colors.lightGreen,
          //   child: const Icon(Icons.add, color: Colors.white),
          // ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "search_vocal".tr(),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Data table
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: _buildTableColumns(userFromStore),
                          rows: _buildAllWordRows(userFromStore),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataColumn> _buildTableColumns(UserModel user) {
    // Lấy chiều rộng màn hình
    final double screenWidth = MediaQuery.of(context).size.width;
    return [
      DataColumn(
        label: SizedBox(
          width: screenWidth * 0.1,
          child: Text(
            user.setting.defaultLanguage.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: screenWidth * 0.1,
          child: Text(
            user.setting.learningLanguages.isNotEmpty
                ? user.setting.learningLanguages[0].tr()
                : 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
          ),
        ),
      ),
      // DataColumn(
      //   label: SizedBox(
      //     width: screenWidth * 0.1,
      //     child: Text(
      //       "topic".tr(),
      //       style: const TextStyle(fontWeight: FontWeight.bold),
      //       overflow: TextOverflow.visible,
      //     ),
      //   ),
      // ),
      DataColumn(
        label: SizedBox(
          width: screenWidth * 0.1,
          child: Text(
            "need_learning".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    ];
  }

  List<DataRow> _buildAllWordRows(UserModel user) {
    final List<DataRow> rows = [];
    final defaultLang = user.setting.defaultLanguage;
    final learningLangs = user.setting.learningLanguages;

    for (var topic in _topics) {
      final wordsInTopic = _topicWords[topic.id] ?? [];
      for (var word in wordsInTopic) {
        List<DataCell> cells = [
          DataCell(Text(word.translations[defaultLang] ?? 'N/A')),
        ];
        // Add cells for all learning languages
        for (var lang in learningLangs) {
          cells.add(DataCell(Text(word.translations[lang] ?? 'N/A')));
        }
        // cells.add(DataCell(Text(topic.name)));
        cells.add(
          DataCell(
            Checkbox(
              value: word.needLearning,
              onChanged: (val) async {
                if (val == null) return;

                // Update local state
                final updatedWord = WordModel(
                  id: word.id,
                  topicId: word.topicId,
                  translations: word.translations,
                  fluentRate: word.fluentRate,
                  tryNumber: word.tryNumber,
                  correctNumber: word.correctNumber,
                  needLearning: val,
                );

                setState(() {
                  final wordIndex = wordsInTopic.indexWhere(
                    (w) => w.id == word.id,
                  );
                  if (wordIndex != -1) {
                    wordsInTopic[wordIndex] = updatedWord;
                  }
                });

                if (val == true) {
                  Fluttertoast.showToast(
                    msg: "Đã thêm từ vào danh sách cần học",
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Đã bỏ từ khỏi danh sách cần học",
                  );
                }
                try {
                  await WordRepository(
                    FirestoreService.instance,
                  ).updateWord(user.id, topic.id, word);
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Failed to update needLearning: $e",
                  );
                }
              },
            ),
          ),
        );
        rows.add(DataRow(cells: cells));
      }
    }
    return rows;
  }
}
