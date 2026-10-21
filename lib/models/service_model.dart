class ServiceVariant {
  final int id;
  final int serviceId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;

  ServiceVariant({
    required this.id,
    required this.serviceId,
    required this.name,
    this.description,
    required this.price,
    this.durationMinutes = 60,
  });

  factory ServiceVariant.fromJson(Map<String, dynamic> json) {
    return ServiceVariant(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      serviceId: json['service_id'] is int ? json['service_id'] : int.tryParse(json['service_id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      durationMinutes: json['duration_minutes'] is int ? json['duration_minutes'] : int.tryParse(json['duration_minutes']?.toString() ?? '60') ?? 60,
    );
  }
}

class ServiceModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final String? categorySlug;
  final String title;
  final String slug;
  final String shortDescription;
  final String description;
  final double basePrice;
  final double? discountPrice;
  final int durationMinutes;
  final String? thumbnail;
  final bool isFeatured;
  final double rating;
  final int totalReviews;
  final String? providerBusinessName;
  final double? providerRating;
  final String? providerMobile;
  final List<ServiceVariant> variants;

  ServiceModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    this.categorySlug,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.basePrice,
    this.discountPrice,
    this.durationMinutes = 60,
    this.thumbnail,
    this.isFeatured = false,
    this.rating = 4.8,
    this.totalReviews = 0,
    this.providerBusinessName,
    this.providerRating,
    this.providerMobile,
    this.variants = const [],
  });

  double get effectivePrice => discountPrice != null && discountPrice! > 0 ? discountPrice! : basePrice;

  bool get hasDiscount => discountPrice != null && discountPrice! > 0 && discountPrice! < basePrice;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((basePrice - discountPrice!) / basePrice) * 100).round();
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json, {List<ServiceVariant>? variantsList}) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      categoryId: json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      categoryName: json['category_name']?.toString() ?? 'Service',
      categorySlug: json['category_slug']?.toString(),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: (json['base_price'] is num) ? (json['base_price'] as num).toDouble() : double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0,
      discountPrice: json['discount_price'] != null ? ((json['discount_price'] is num) ? (json['discount_price'] as num).toDouble() : double.tryParse(json['discount_price'].toString())) : null,
      durationMinutes: json['duration_minutes'] is int ? json['duration_minutes'] : int.tryParse(json['duration_minutes']?.toString() ?? '60') ?? 60,
      thumbnail: json['thumbnail']?.toString() ?? 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : double.tryParse(json['rating']?.toString() ?? '4.8') ?? 4.8,
      totalReviews: json['total_reviews'] is int ? json['total_reviews'] : int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      providerBusinessName: json['provider_business_name']?.toString() ?? json['business_name']?.toString(),
      providerRating: json['provider_rating'] != null ? double.tryParse(json['provider_rating'].toString()) : null,
      providerMobile: json['provider_mobile']?.toString(),
      variants: variantsList ?? [],
    );
  }
}
