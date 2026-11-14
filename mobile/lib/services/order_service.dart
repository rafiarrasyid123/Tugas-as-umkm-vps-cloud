import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../models/order_model.dart';
import 'auth_service.dart';

class OrderService {
  static Future<Map<String, dynamic>> createOrder({
    required int packageId,
    int durationMonths = 1,
    String paymentMethod = 'bca_va',
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.orders),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'package_id': packageId,
          'duration_months': durationMonths,
          'payment_method': paymentMethod,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'Pesanan berhasil dibuat',
          'data': OrderModel.fromJson(body['data']),
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat pesanan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  static Future<List<OrderModel>> getMyOrders() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.myOrders),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List;
          return list.map((item) => OrderModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<OrderModel?> getOrderById(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.orderDetail(id)),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return OrderModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> payOrder(int id) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.patch(
        Uri.parse(ApiConstants.payOrder(id)),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body['success'] == true) {
        return {
          'success': true,
          'message': body['message'] ?? 'Pembayaran berhasil dikonfirmasi',
          'data': OrderModel.fromJson(body['data']),
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Gagal memproses pembayaran',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  static Future<List<OrderModel>> getAllOrders() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.orders),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final list = body['data'] as List;
          return list.map((item) => OrderModel.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
