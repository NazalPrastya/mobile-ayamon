import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userIdKey = 'user_id';

  // ── Login ────────────────────────────────────────────────────────────────────
  /// Returns null jika berhasil, atau pesan error jika gagal.
  Future<String?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['status'] == 'success') {
        final data = body['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await _saveSession(token, user);
        return null; // sukses
      }

      return (body['message'] as String?) ?? 'Login gagal. Coba lagi.';
    } on TimeoutException {
      return 'Request timeout. Pastikan server sedang berjalan.';
    } on FormatException catch (e) {
      return 'Format response tidak valid: $e';
    } on TypeError catch (e) {
      return 'Parsing data gagal: $e';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Get Me ───────────────────────────────────────────────────────────────────
  Future<UserModel?> getMe() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getMeUrl),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['status'] == 'success') {
        return UserModel.fromJson(body['data']);
      }
    } catch (_) {}
    return null;
  }

  // ── Session helpers ───────────────────────────────────────────────────────────
  Future<void> _saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Register ─────────────────────────────────────────────────────────────────
  /// Returns null jika berhasil, atau pesan error jika gagal.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          body['status'] == 'success') {
        return null; // sukses
      }

      return body['message'] ?? 'Registrasi gagal. Coba lagi.';
    } catch (e) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http
            .post(
              Uri.parse(ApiConfig.logoutUrl),
              headers: {'Authorization': 'Bearer $token'},
            )
            .timeout(const Duration(seconds: 10));
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
