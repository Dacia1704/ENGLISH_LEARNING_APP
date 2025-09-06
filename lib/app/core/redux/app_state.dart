import 'package:english_learning_app/app/data/models/user_model.dart';

class AppState {
  final UserModel? user;

  AppState({this.user});

  AppState copyWith({UserModel? user}) {
    return AppState(user: user ?? this.user);
  }

  factory AppState.initial() => AppState(user: null);
}
