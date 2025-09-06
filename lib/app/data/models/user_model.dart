import 'package:english_learning_app/app/data/models/setting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final SettingModel setting;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    required this.setting,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      id: doc.id,
      email: data['email'],
      fullName: data['fullName'],
      setting: data['setting'] != null
          ? SettingModel.fromMap(data['setting'])
          : SettingModel.defaultSetting(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'setting': setting.toFirestore(),
    };
  }

  @override
  String toString() {
    return "UserModel: {id: $id, email: $email, fullName: $fullName, setting: $setting}";
  }
}
