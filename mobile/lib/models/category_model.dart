class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int totalPackages;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.totalPackages = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      totalPackages: json['total_packages'] != null
          ? int.tryParse(json['total_packages'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'total_packages': totalPackages,
    };
  }
}
