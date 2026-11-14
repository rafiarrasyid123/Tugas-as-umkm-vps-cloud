import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/category_model.dart';
import 'auth_service.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.categories),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List;
          return list.map((item) => CategoryModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.categories),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 201 && body['success'] == true) {
        return {'success': true, 'message': body['message'] ?? 'Kategori dibuat'};
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal membuat kategori'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }
}
