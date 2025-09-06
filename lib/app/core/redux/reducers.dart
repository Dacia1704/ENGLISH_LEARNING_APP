import 'app_state.dart';
import 'actions.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserAction) {
    return state.copyWith(user: action.user);
  } else if (action is ClearUserAction) {
    return state.copyWith(user: null);
  }
  return state;
}
