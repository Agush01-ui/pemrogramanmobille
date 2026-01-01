import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_helper.dart';

class AuthProvider extends ChangeNotifier {
  String? username;
  bool isLoggedIn = false;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    username = prefs.getString('last_username');
    notifyListeners();
  }

  Future<bool> login(String user, String pass) async {
    bool valid = await DatabaseHelper.instance.loginUser(user, pass);
    if (valid) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('last_username', user);
      username = user;
      isLoggedIn = true;
      notifyListeners();
    }
    return valid;
  }

  Future<int> register(String user, String pass) async {
    int result = await DatabaseHelper.instance.registerUser(user, pass);
    return result;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    username = null;
    isLoggedIn = false;
    notifyListeners();
  }
}
