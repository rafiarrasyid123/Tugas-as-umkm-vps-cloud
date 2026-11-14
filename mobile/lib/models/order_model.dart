class OrderModel {
  final int id;
  final String orderNumber;
  final int userId;
  final int packageId;
  final int durationMonths;
  final double totalPrice;
  final String status; // 'pending', 'active', 'cancelled'
  final String paymentMethod;
  final String? paymentCode;
  final String? serverIp;
  final String? packageName;
  final String? packageImage;
  final String? categoryName;
  final int? cpuCores;
  final int? ramGb;
  final int? storageGb;
  final int? bandwidthTb;
  final String? clientName;
  final String? clientEmail;
  final DateTime? createdAt;
  final DateTime? paidAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.packageId,
    required this.durationMonths,
    required this.totalPrice,
    required this.status,
    required this.paymentMethod,
    this.paymentCode,
    this.serverIp,
    this.packageName,
    this.packageImage,
    this.categoryName,
    this.cpuCores,
    this.ramGb,
    this.storageGb,
    this.bandwidthTb,
    this.clientName,
    this.clientEmail,
    this.createdAt,
    this.paidAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isActive => status.toLowerCase() == 'active';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      orderNumber: json['order_number']?.toString() ?? '',
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      packageId: json['package_id'] is int
          ? json['package_id']
          : int.tryParse(json['package_id']?.toString() ?? '0') ?? 0,
      durationMonths: json['duration_months'] is int
          ? json['duration_months']
          : int.tryParse(json['duration_months']?.toString() ?? '1') ?? 1,
      totalPrice: json['total_price'] is num
          ? (json['total_price'] as num).toDouble()
          : double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString() ?? 'bca_va',
      paymentCode: json['payment_code']?.toString(),
      serverIp: json['server_ip']?.toString(),
      packageName: json['package_name']?.toString(),
      packageImage: json['package_image']?.toString(),
      categoryName: json['category_name']?.toString(),
      cpuCores: json['cpu_cores'] != null
          ? int.tryParse(json['cpu_cores'].toString())
          : null,
      ramGb: json['ram_gb'] != null
          ? int.tryParse(json['ram_gb'].toString())
          : null,
      storageGb: json['storage_gb'] != null
          ? int.tryParse(json['storage_gb'].toString())
          : null,
      bandwidthTb: json['bandwidth_tb'] != null
          ? int.tryParse(json['bandwidth_tb'].toString())
          : null,
      clientName: json['client_name']?.toString(),
      clientEmail: json['client_email']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'package_id': packageId,
      'duration_months': durationMonths,
      'total_price': totalPrice,
      'status': status,
      'payment_method': paymentMethod,
      'payment_code': paymentCode,
      'server_ip': serverIp,
      'package_name': packageName,
      'package_image': packageImage,
      'category_name': categoryName,
      'cpu_cores': cpuCores,
      'ram_gb': ramGb,
      'storage_gb': storageGb,
      'bandwidth_tb': bandwidthTb,
      'client_name': clientName,
      'client_email': clientEmail,
      'created_at': createdAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
    };
  }
}
