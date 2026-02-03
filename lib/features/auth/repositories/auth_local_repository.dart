import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalRepository {
  late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  void setToken(String? token) {
    if (token != null) {
      _sharedPreferences.setString('X-auth-token', token);
    }
  }

  String? getToken(String? token) {
    if (token != null) {
      return _sharedPreferences.getString('X-auth-token');
    }
    return null;
  }
}
