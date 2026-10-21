import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';
import '../services/api_service.dart';
import '../config/api_constants.dart';

class ServiceCatalogProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  List<ServiceModel> _featuredServices = [];
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _selectedCategorySlug;
  String _searchQuery = '';

  List<CategoryModel> get categories => _categories;
  List<ServiceModel> get featuredServices => _featuredServices;
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get selectedCategorySlug => _selectedCategorySlug;
  String get searchQuery => _searchQuery;

  /// Fetch all categories from backend
  Future<void> fetchCategories() async {
    try {
      final res = await _apiService.get(ApiConstants.categories);
      if (res.success && res.data != null && res.data['categories'] != null) {
        final list = res.data['categories'] as List;
        _categories = list.map((c) => CategoryModel.fromJson(c)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Fetch services with optional filters
  Future<void> fetchServices({
    String? categorySlug,
    String? city,
    String? query,
    String? sort,
  }) async {
    _isLoading = true;
    _selectedCategorySlug = categorySlug;
    if (query != null) _searchQuery = query;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (_selectedCategorySlug != null && _selectedCategorySlug!.isNotEmpty && _selectedCategorySlug != 'all') {
        queryParams['category'] = _selectedCategorySlug!;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (_searchQuery.isNotEmpty) {
        queryParams['q'] = _searchQuery;
      }
      if (sort != null) {
        queryParams['sort'] = sort;
      }

      final res = await _apiService.get(ApiConstants.services, queryParams: queryParams);
      if (res.success && res.data != null && res.data['services'] != null) {
        final list = res.data['services'] as List;
        _services = list.map((s) => ServiceModel.fromJson(s)).toList();

        // Also update featured list if not set yet
        if (_featuredServices.isEmpty) {
          _featuredServices = _services.where((s) => s.isFeatured).toList();
          if (_featuredServices.isEmpty && _services.isNotEmpty) {
            _featuredServices = _services.take(6).toList();
          }
        }
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch service details by slug
  Future<ServiceModel?> getServiceDetail(String slug) async {
    try {
      final res = await _apiService.get('${ApiConstants.services}/$slug');
      if (res.success && res.data != null && res.data['service'] != null) {
        final sJson = res.data['service'] as Map<String, dynamic>;
        final vJson = (res.data['variants'] as List?)
                ?.map((v) => ServiceVariant.fromJson(v as Map<String, dynamic>))
                .toList() ??
            [];
        return ServiceModel.fromJson(sJson, variantsList: vJson);
      }
    } catch (_) {}
    return null;
  }
}
