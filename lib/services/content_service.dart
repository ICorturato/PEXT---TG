import 'package:flutter/foundation.dart';

import '../models/app_category.dart';
import '../models/content_model.dart';
import 'api_client.dart';

class ContentService extends ChangeNotifier {
  static final ContentService instance = ContentService._internal();
  ContentService._internal();

  final List<ContentModel> _contents = [];
  List<AppCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ContentModel> get contents => List.unmodifiable(_contents);
  List<AppCategory> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setContentsForTest(List<ContentModel> items) {
    _contents.clear();
    _contents.addAll(items);
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final list = await ApiClient.instance.categories(CategoryScope.content);
      _categories = list;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading content categories: $e');
    }
  }

  Future<List<ContentModel>> fetchContents(
      {String? query, String? status, bool includeInactive = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String>[];
      if (query != null && query.isNotEmpty) {
        queryParams.add('q=${Uri.encodeQueryComponent(query)}');
      }
      if (status != null && status.isNotEmpty) {
        queryParams.add('status=${Uri.encodeQueryComponent(status)}');
      }
      if (includeInactive) {
        queryParams.add('includeInactive=true');
      }
      final suffix =
          queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final payload = await ApiClient.instance.getRaw('/contents$suffix');
      final items = List<Map<String, dynamic>>.from(
          (payload['items'] as List? ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map)));

      _contents.clear();
      for (final item in items) {
        _contents.add(ContentModel.fromJson(item));
      }
      await loadCategories();
      _isLoading = false;
      notifyListeners();
      return _contents;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return _contents;
    }
  }

  Future<ContentModel> createContent({
    required String title,
    required String text,
    String? categoryId,
    String? categoryName,
    String? documentName,
    String? documentUrl,
    String? documentSize,
  }) async {
    final payload = await ApiClient.instance.postRaw('/contents', {
      'title': title,
      'text': text,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'documentSize': documentSize,
    });
    final created = ContentModel.fromJson(payload);
    _contents.removeWhere((c) => c.id == created.id);
    _contents.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<ContentModel> updateContent(
    String id, {
    required String title,
    required String text,
    String? categoryId,
    String? categoryName,
    String? documentName,
    String? documentUrl,
    String? documentSize,
    String? changeNote,
  }) async {
    final payload = await ApiClient.instance.putRaw('/contents/$id', {
      'title': title,
      'text': text,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'documentSize': documentSize,
      if (changeNote != null) 'changeNote': changeNote,
    });
    final updated = ContentModel.fromJson(payload);
    final index = _contents.indexWhere((c) => c.id == id);
    if (index != -1) {
      _contents[index] = updated;
    } else {
      _contents.insert(0, updated);
    }
    notifyListeners();
    return updated;
  }

  Future<void> deleteContent(String id) async {
    await ApiClient.instance.deleteRaw('/contents/$id');
    final index = _contents.indexWhere((c) => c.id == id);
    if (index != -1) {
      _contents[index] = _contents[index].copyWith(status: 'INACTIVE', isDeleted: true);
    }
    notifyListeners();
  }
}
