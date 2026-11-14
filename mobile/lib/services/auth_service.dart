import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        return UserModel.fromJson(jsonDecode(userStr));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token'];
        final user = UserModel.fromJson(data['data']['user']);
        await saveToken(token);
        await saveUser(user);
        return {'success': true, 'message': data['message'] ?? 'Login berhasil', 'user': user};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String role = 'client',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Registrasi berhasil'};
      } else {
        // Ambil pesan error validasi Zod jika ada
        String errorMessage = data['message'] ?? 'Registrasi gagal';
        if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
          final firstError = data['errors'][0];
          errorMessage = "${firstError['field']}: ${firstError['message']}";
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<UserModel?> fetchProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(ApiConstants.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          final user = UserModel.fromJson(data['data']);
          await saveUser(user);
          return user;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

