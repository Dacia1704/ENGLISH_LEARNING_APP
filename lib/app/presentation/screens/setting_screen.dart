import 'package:english_learning_app/app/core/redux/actions.dart';
import 'package:english_learning_app/app/data/models/setting_model.dart';
import 'package:english_learning_app/app/data/repositories/user_repository.dart';
import 'package:english_learning_app/app/data/services/firestore_service.dart';
import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:english_learning_app/app/core/redux/app_state.dart';
import 'package:english_learning_app/app/data/models/user_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late SettingModel _settings;

  final _userRepo = UserRepository(FirestoreService.instance);

  final List<String> availableLanguages = ["vi-VI", "en-US"];

  bool _isSaving = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = StoreProvider.of<AppState>(context);
    final user = store.state.user;

    // Nếu user.setting null thì gán default
    _settings = user?.setting.copy() ?? SettingModel.defaultSetting();
  }

  void _toggleQuizEnable() {
    final store = StoreProvider.of<AppState>(context);
    final currentUser = store.state.user!;

    // Tạo setting mới
    final newSetting = SettingModel(
      defaultLanguage: currentUser.setting.defaultLanguage,
      learningLanguages: List<String>.from(
        currentUser.setting.learningLanguages,
      ),
      quizInterval: currentUser.setting.quizInterval,
      quizAnswerTime: currentUser.setting.quizAnswerTime,
      quizEnable: !currentUser.setting.quizEnable, // toggle
    );

    // Tạo user mới
    final newUser = UserModel(
      id: currentUser.id,
      email: currentUser.email,
      fullName: currentUser.fullName,
      setting: newSetting,
    );

    store.dispatch(SetUserAction(newUser));
    _userRepo.updateUser(newUser);

    setState(() {
      _settings = newSetting;
    });
  }

  Future<void> _saveSettings() async {
    final store = StoreProvider.of<AppState>(context);
    final user = store.state.user;

    if (user != null) {
      setState(() {
        _isSaving = true; // bắt đầu loading
      });

      UserModel newUser = store.state.user!;
      newUser.setting = _settings;

      store.dispatch(SetUserAction(newUser));
      Locale newLocale;
      if (newUser.setting.defaultLanguage == 'vi-VI') {
        newLocale = Locale('vi', 'VI');
      } else {
        newLocale = Locale('en', 'US');
      }
      await context.setLocale(newLocale);
      try {
        await _userRepo.updateUser(newUser); // chờ update xong
        Fluttertoast.showToast(msg: "update_setting_successful".tr());
      } catch (e) {
        Fluttertoast.showToast(msg: "update_setting_failed".tr());
      } finally {
        setState(() {
          _isSaving = false; // kết thúc loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserModel?>(
      converter: (store) => store.state.user,
      builder: (context, userFromStore) {
        if (userFromStore == null) {
          return Scaffold(
            body: Center(child: Text("no_user_data_in_store".tr())),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text("setting".tr()), centerTitle: true),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 24),
              // Button tròn bật/tắt quiz
              Center(
                child: GestureDetector(
                  onTap: _toggleQuizEnable,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: _settings.quizEnable
                          ? Colors.green
                          : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _settings.quizEnable ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 96,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quiz Interval
              ListTile(
                title: Text("quiz_interval".tr()),
                trailing: DropdownButton<int>(
                  value: _settings.quizInterval,
                  items: [
                    DropdownMenuItem(
                      value: 15 * 60,
                      child: Text(tr('minutes', args: ["15"])),
                    ),
                    DropdownMenuItem(
                      value: 30 * 60,
                      child: Text(tr('minutes', args: ["30"])),
                    ),
                    DropdownMenuItem(
                      value: 60 * 60,
                      child: Text(tr('minutes', args: ["60"])),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings.quizInterval = value;
                      });
                    }
                  },
                ),
              ),

              // Quiz Answer Time
              ListTile(
                title: Text("quiz_answer_time".tr()),
                trailing: DropdownButton<int>(
                  value: _settings.quizAnswerTime,
                  items: [
                    DropdownMenuItem(
                      value: 5,
                      child: Text(tr('seconds', args: ["5"])),
                    ),
                    DropdownMenuItem(
                      value: 10,
                      child: Text(tr('seconds', args: ["10"])),
                    ),
                    DropdownMenuItem(
                      value: 20,
                      child: Text(tr('seconds', args: ["20"])),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings.quizAnswerTime = value;
                      });
                    }
                  },
                ),
              ),

              // Default Language
              ListTile(
                title: Text("default_language".tr()),
                trailing: DropdownButton<String>(
                  value: _settings.defaultLanguage,
                  items: availableLanguages
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang.tr()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _settings.defaultLanguage = value;
                      });
                    }
                  },
                ),
              ),

              // Learning Languages
              ExpansionTile(
                title: Text("learning_language".tr()),
                children: availableLanguages.map((lang) {
                  final selected = _settings.learningLanguages.contains(lang);
                  return CheckboxListTile(
                    title: Text(lang.tr()),
                    value: selected,
                    onChanged: (checked) {
                      setState(() {
                        final updatedList = List<String>.from(
                          _settings.learningLanguages,
                        );
                        if (checked == true) {
                          updatedList.add(lang);
                        } else {
                          updatedList.remove(lang);
                        }
                        _settings.learningLanguages = updatedList;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("save".tr(), style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }
}
