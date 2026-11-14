class PackageModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String? slug;
  final int cpuCores;
  final int ramGb;
  final int storageGb;
  final int bandwidthTb;
  final double pricePerMonth;
  final int stockAvailable;
  final String? imageUrl;
  final String? description;
  final String? createdByName;

  PackageModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.slug,
    required this.cpuCores,
    required this.ramGb,
    required this.storageGb,
    required this.bandwidthTb,
    required this.pricePerMonth,
    required this.stockAvailable,
    this.imageUrl,
    this.description,
    this.createdByName,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      cpuCores: json['cpu_cores'] is int
          ? json['cpu_cores']
          : int.tryParse(json['cpu_cores']?.toString() ?? '1') ?? 1,
      ramGb: json['ram_gb'] is int
          ? json['ram_gb']
          : int.tryParse(json['ram_gb']?.toString() ?? '1') ?? 1,
      storageGb: json['storage_gb'] is int
          ? json['storage_gb']
          : int.tryParse(json['storage_gb']?.toString() ?? '10') ?? 10,
      bandwidthTb: json['bandwidth_tb'] is int
          ? json['bandwidth_tb']
          : int.tryParse(json['bandwidth_tb']?.toString() ?? '1') ?? 1,
      pricePerMonth: json['price_per_month'] is num
          ? (json['price_per_month'] as num).toDouble()
          : double.tryParse(json['price_per_month']?.toString() ?? '0') ?? 0.0,
      stockAvailable: json['stock_available'] is int
          ? json['stock_available']
          : int.tryParse(json['stock_available']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString(),
      description: json['description']?.toString(),
      createdByName: json['created_by_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'name': name,
      'slug': slug,
      'cpu_cores': cpuCores,
      'ram_gb': ramGb,
      'storage_gb': storageGb,
      'bandwidth_tb': bandwidthTb,
      'price_per_month': pricePerMonth,
      'stock_available': stockAvailable,
      'image_url': imageUrl,
      'description': description,
      'created_by_name': createdByName,
    };
  }
}
