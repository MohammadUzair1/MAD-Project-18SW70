import 'package:chat_app/enum/user_state.dart';
import 'package:random_string/random_string.dart' as random;

class Utils {
  static String randomString(int length) {
    return random.randomNumeric(length);
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.Offline:
        return 0;
      case UserState.Online:
        return 1;
      default:
        return 2;
    }
  }

  static UserState numToState(int number) {
    switch (number) {
      case 0:
        return UserState.Offline;
      case 1:
        return UserState.Online;
      default:
        return UserState.Waiting;
    }
  }
}
