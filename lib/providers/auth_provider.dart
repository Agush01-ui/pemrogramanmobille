import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyUsername = 'current_user';
  static const _keyUsers = 'users_db';

  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _username;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get username => _username;

  AuthProvider() {
    _loadSession();
  }

  /// ================= LOAD SESSION =================
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    _username = prefs.getString(_keyUsername);
    _isLoading = false;
    notifyListeners();
  }

  /// ================= REGISTER =================
  Future<String?> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_keyUsers);
    final Map<String, dynamic> users = raw == null ? {} : jsonDecode(raw);

    if (users.containsKey(username)) {
      return 'Username sudah terdaftar';
    }

    users[username] = _hash(password);
    await prefs.setString(_keyUsers, jsonEncode(users));

    return null; // sukses
  }

  /// ================= LOGIN =================
  Future<String?> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_keyUsers);
    if (raw == null) return 'User tidak ditemukan';

    final Map<String, dynamic> users = jsonDecode(raw);

    if (!users.containsKey(username)) {
      return 'Username tidak ditemukan';
    }

    if (users[username] != _hash(password)) {
      return 'Password salah';
    }

    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUsername, username);

    _username = username;
    _isLoggedIn = true;
    notifyListeners();

    return null; // sukses
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyUsername);

    _isLoggedIn = false;
    _username = null;
    notifyListeners();
  }

  /// ================= SIMPLE HASH =================
  String _hash(String input) {
    return base64Encode(utf8.encode(input));
  }
}
