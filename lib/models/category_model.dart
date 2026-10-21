class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? image;
  final String? description;
  final int serviceCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.image,
    this.description,
    this.serviceCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      image: json['image']?.toString(),
      description: json['description']?.toString(),
      serviceCount: json['services_count'] is int
          ? json['services_count']
          : int.tryParse(json['services_count']?.toString() ?? '0') ?? 0,
    );
  }

  // Get a readable material icon or fallback
  String get displayIcon {
    if (icon != null && icon!.isNotEmpty) return icon!;
    return 'category';
  }
}
