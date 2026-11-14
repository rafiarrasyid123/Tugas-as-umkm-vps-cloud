import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/package_model.dart';
import 'auth_service.dart';

class PackageService {
  static Future<List<PackageModel>> getPackages({
    int? categoryId,
    String? search,
    String? sort,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (categoryId != null && categoryId > 0) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final uri = Uri.parse(ApiConstants.packages).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List;
          return list.map((item) => PackageModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<PackageModel?> getPackageById(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.packageDetail(id)),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return PackageModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> deletePackage(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse(ApiConstants.packageDetail(id)),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message'] ?? 'Paket berhasil dihapus'};
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal menghapus paket'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  static Future<Map<String, dynamic>> createPackage({
    required int categoryId,
    required String name,
    required int cpuCores,
    required int ramGb,
    required int storageGb,
    required int bandwidthTb,
    required double pricePerMonth,
    required int stockAvailable,
    String? description,
    File? imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse(ApiConstants.packages);
      final request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['category_id'] = categoryId.toString();
      request.fields['name'] = name;
      request.fields['cpu_cores'] = cpuCores.toString();
      request.fields['ram_gb'] = ramGb.toString();
      request.fields['storage_gb'] = storageGb.toString();
      request.fields['bandwidth_tb'] = bandwidthTb.toString();
      request.fields['price_per_month'] = pricePerMonth.toStringAsFixed(2);
      request.fields['stock_available'] = stockAvailable.toString();
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      if (imageFile != null && await imageFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'Paket berhasil ditambahkan',
          'data': body['data'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal menambahkan paket',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }

  static Future<Map<String, dynamic>> updatePackage({
    required int id,
    int? categoryId,
    String? name,
    int? cpuCores,
    int? ramGb,
    int? storageGb,
    int? bandwidthTb,
    double? pricePerMonth,
    int? stockAvailable,
    String? description,
    File? imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse(ApiConstants.packageDetail(id));
      final request = http.MultipartRequest('PUT', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      if (categoryId != null) request.fields['category_id'] = categoryId.toString();
      if (name != null) request.fields['name'] = name;
      if (cpuCores != null) request.fields['cpu_cores'] = cpuCores.toString();
      if (ramGb != null) request.fields['ram_gb'] = ramGb.toString();
      if (storageGb != null) request.fields['storage_gb'] = storageGb.toString();
      if (bandwidthTb != null) request.fields['bandwidth_tb'] = bandwidthTb.toString();
      if (pricePerMonth != null) {
        request.fields['price_per_month'] = pricePerMonth.toStringAsFixed(2);
      }
      if (stockAvailable != null) {
        request.fields['stock_available'] = stockAvailable.toString();
      }
      if (description != null) request.fields['description'] = description;

      if (imageFile != null && await imageFile.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'Paket berhasil diperbarui',
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal memperbarui paket',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan jaringan: $e'};
    }
  }
}
