import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';

  String? accessToken;
  String? refreshToken;
  String? username;
  String? email;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_accessKey);
    refreshToken = prefs.getString(_refreshKey);
    username = prefs.getString(_usernameKey);
    email = prefs.getString(_emailKey);
  }

  Future<void> save({
    required String access,
    required String refresh,
    required String username,
    required String email,
  }) async {
    accessToken = access;
    refreshToken = refresh;
    this.username = username;
    this.email = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_emailKey, email);
  }

  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    username = null;
    email = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  bool get hasToken => accessToken != null && accessToken!.isNotEmpty;
}
