import 'package:flutter/foundation.dart';
import 'package:hard_diffusion/main.dart';

class AuthState extends ChangeNotifier {
  AuthState() {
    username = prefs!.getString("username") ?? "";
  }
  String username = "";
  String refreshToken = "";
  String accessToken = "";

  void setUsername(value) {
    username = value;
    prefs!.setString("username", username);
    notifyListeners();
  }

  void setAccessToken(String token) {
    accessToken = token;
    //notifyListeners();
  }

  void setRefreshToken(String token) {
    refreshToken = token;
    //notifyListeners();
  }
}
