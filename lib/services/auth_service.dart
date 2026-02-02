import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  static const String _userPrefix = 'user_';

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<String?> register(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('$_userPrefix$login')) {
      return 'Пользователь с таким логином уже существует';
    }

    await prefs.setString('$_userPrefix$login', _hashPassword(password));
    return null;
  }


  Future<bool> login(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString('$_userPrefix$login');

    if (storedHash == null) return false;
    return storedHash == _hashPassword(password);
  }
}