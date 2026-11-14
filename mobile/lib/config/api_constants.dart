class ApiConstants {
  // Base URL ke Backend Vercel Live
  static const String baseUrl = 'https://tugas-as-umkm-vps-cloud-8hk2.vercel.app/api';

  // Endpoint Rute
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get profile => '$baseUrl/auth/profile';
  static String get categories => '$baseUrl/categories';
  static String get packages => '$baseUrl/packages';
  static String packageDetail(int id) => '$baseUrl/packages/$id';

  // Endpoint Transaksi & Sewa Server
  static String get orders => '$baseUrl/orders';
  static String get myOrders => '$baseUrl/orders/my-orders';
  static String orderDetail(int id) => '$baseUrl/orders/$id';
  static String payOrder(int id) => '$baseUrl/orders/$id/pay';
}
