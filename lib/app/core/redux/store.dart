import 'package:redux/redux.dart';
import 'app_state.dart';
import 'reducers.dart';

final Store<AppState> store = Store<AppState>(
  appReducer,
  initialState: AppState.initial(),
);
