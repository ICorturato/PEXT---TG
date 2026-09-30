import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_category.dart';
import '../models/resin_model.dart';
import 'api_client.dart';

class ResinService extends ChangeNotifier {
  ResinService._();
  static final ResinService instance = ResinService._();

  final List<ResinModel> _resins = [];
  List<AppCategory> _categories = [];
  final Set<String> _favoriteIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<ResinModel> get resins => List.unmodifiable(_resins);
  List<AppCategory> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _ensureAuth() async {
    if (ApiClient.instance.session.token == null) {
      try {
        await ApiClient.instance.login('admin@pext.local', 'admin123');
      } catch (_) {}
    }
  }

  Future<List<AppCategory>> loadCategories() async {
    await _ensureAuth();
    try {
      _categories = await ApiClient.instance.categories(CategoryScope.resin);
      notifyListeners();
    } catch (_) {}
    return _categories;
  }

  String? _resolveCategoryName(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return null;
    final match = _categories.where((c) => c.id == categoryId);
    if (match.isNotEmpty) return match.first.name;
    return null;
  }

  Future<List<ResinModel>> fetchResins({String? query}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureAuth();
      await loadCategories();

      // Fetch favorites
      try {
        final favResponse = await http
            .get(
              Uri.parse('${ApiClient.baseUrl}/favorites'),
              headers: ApiClient.instance.headers,
            )
            .timeout(const Duration(seconds: 10));
        if (favResponse.statusCode == 200) {
          final List favList = jsonDecode(favResponse.body) as List? ?? [];
          _favoriteIds.clear();
          for (final item in favList) {
            if (item is Map &&
                item['entityType']?.toString().toUpperCase() == 'RESIN') {
              _favoriteIds.add(item['entityId']?.toString() ?? '');
            }
          }
        }
      } catch (_) {}

      // Fetch resins from API
      final endpoint = (query != null && query.trim().isNotEmpty)
          ? '/resins?q=${Uri.encodeQueryComponent(query.trim())}'
          : '/resins';
      final response = await http
          .get(
            Uri.parse('${ApiClient.baseUrl}$endpoint'),
            headers: ApiClient.instance.headers,
          )
          .timeout(const Duration(seconds: 10));

      final payload = jsonDecode(response.body);
      final List rawItems = (payload is Map && payload['items'] is List)
          ? payload['items'] as List
          : (payload is List ? payload : []);

      final List<ResinModel> loaded = [];
      for (final item in rawItems) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final id = map['id']?.toString() ?? '';
          final catId = map['categoryId']?.toString();
          final catName = _resolveCategoryName(catId) ??
              map['categoryName']?.toString();
          final isFav = _favoriteIds.contains(id);

          loaded.add(ResinModel.fromJson(
            map,
            isFavorite: isFav,
            categoryName: catName,
          ));
        }
      }

      // Sort alphabetically by name
      loaded.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      // Apply client-side search filter if query is present
      List<ResinModel> filtered = loaded;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        filtered = loaded
            .where((r) =>
                r.name.toLowerCase().contains(q) ||
                r.acronym.toLowerCase().contains(q) ||
                (r.categoryName ?? '').toLowerCase().contains(q))
            .toList();
      }

      _resins
        ..clear()
        ..addAll(filtered);
      _isLoading = false;
      notifyListeners();
      return _resins;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return _resins;
    }
  }

  Future<ResinModel> getResinById(String id) async {
    await _ensureAuth();
    if (_categories.isEmpty) {
      await loadCategories();
    }

    final response = await http
        .get(
          Uri.parse('${ApiClient.baseUrl}/resins/$id'),
          headers: ApiClient.instance.headers,
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final catId = map['categoryId']?.toString();
      final catName =
          _resolveCategoryName(catId) ?? map['categoryName']?.toString();
      final isFav = _favoriteIds.contains(id);

      return ResinModel.fromJson(
        map,
        isFavorite: isFav,
        categoryName: catName,
      );
    }
    throw ApiException('Não foi possível obter os dados da resina.');
  }

  Future<ResinModel> createResin(
    ResinModel resin, {
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureAuth();

      String? uploadedImageUrl = resin.imageUrl;
      if (imageBytes != null &&
          imageBytes.isNotEmpty &&
          imageFilename != null &&
          imageFilename.isNotEmpty) {
        final ext = imageFilename.toLowerCase().endsWith('.png') ? '.png' : '.jpg';
        final mime = ext == '.png' ? 'image/png' : 'image/jpeg';
        uploadedImageUrl = await ApiClient.instance.uploadMediaBytes(
          bytes: imageBytes,
          filename: imageFilename,
          contentType: mime,
        );
      }

      final toSend = resin.copyWith(imageUrl: uploadedImageUrl);
      final jsonBody = toSend.toJson();

      final response = await http
          .post(
            Uri.parse('${ApiClient.baseUrl}/resins'),
            headers: ApiClient.instance.headers,
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        final catId = map['categoryId']?.toString();
        final catName = _resolveCategoryName(catId) ?? toSend.categoryName;
        final created = ResinModel.fromJson(map, categoryName: catName);

        _resins.add(created);
        _resins.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _isLoading = false;
        notifyListeners();
        return created;
      }
      final err = jsonDecode(response.body);
      throw ApiException(err['error']?.toString() ?? 'Erro ao cadastrar resina.');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<ResinModel> updateResin(
    String id,
    ResinModel updatedResin, {
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureAuth();

      String? uploadedImageUrl = updatedResin.imageUrl;
      if (imageBytes != null &&
          imageBytes.isNotEmpty &&
          imageFilename != null &&
          imageFilename.isNotEmpty) {
        final ext = imageFilename.toLowerCase().endsWith('.png') ? '.png' : '.jpg';
        final mime = ext == '.png' ? 'image/png' : 'image/jpeg';
        uploadedImageUrl = await ApiClient.instance.uploadMediaBytes(
          bytes: imageBytes,
          filename: imageFilename,
          contentType: mime,
        );
      }

      final toSend = updatedResin.copyWith(imageUrl: uploadedImageUrl);
      final jsonBody = toSend.toJson();

      final response = await http
          .put(
            Uri.parse('${ApiClient.baseUrl}/resins/$id'),
            headers: ApiClient.instance.headers,
            body: jsonEncode(jsonBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        final catId = map['categoryId']?.toString();
        final catName = _resolveCategoryName(catId) ?? toSend.categoryName;
        final updated = ResinModel.fromJson(
          map,
          isFavorite: _favoriteIds.contains(id),
          categoryName: catName,
        );

        final index = _resins.indexWhere((r) => r.id == id);
        if (index != -1) {
          _resins[index] = updated;
        } else {
          _resins.add(updated);
        }
        _resins.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _isLoading = false;
        notifyListeners();
        return updated;
      }
      final err = jsonDecode(response.body);
      throw ApiException(err['error']?.toString() ?? 'Erro ao atualizar resina.');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteResin(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureAuth();
      final response = await http
          .delete(
            Uri.parse('${ApiClient.baseUrl}/resins/$id'),
            headers: ApiClient.instance.headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _resins.removeWhere((r) => r.id == id);
        _isLoading = false;
        notifyListeners();
        return;
      }
      final err = jsonDecode(response.body);
      throw ApiException(err['error']?.toString() ?? 'Erro ao excluir resina.');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> toggleFavorite(String resinId) async {
    await _ensureAuth();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiClient.baseUrl}/favorites/toggle'),
            headers: ApiClient.instance.headers,
            body: jsonEncode({
              'entityType': 'RESIN',
              'entityId': resinId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final payload = jsonDecode(response.body) as Map;
        final bool isFav = payload['favorite'] == true;
        if (isFav) {
          _favoriteIds.add(resinId);
        } else {
          _favoriteIds.remove(resinId);
        }

        final index = _resins.indexWhere((r) => r.id == resinId);
        if (index != -1) {
          _resins[index] = _resins[index].copyWith(isFavorite: isFav);
        }
        notifyListeners();
        return isFav;
      }
    } catch (_) {}
    return false;
  }

  Future<ResinDocument> uploadDocument({
    required Uint8List bytes,
    required String filename,
  }) async {
    await _ensureAuth();
    final url = await ApiClient.instance.uploadMediaBytes(
      bytes: bytes,
      filename: filename,
      contentType: 'application/pdf',
    );
    final sizeMb = (bytes.length / (1024 * 1024)).toStringAsFixed(1);
    final ext = filename.contains('.')
        ? filename.substring(filename.lastIndexOf('.') + 1).toUpperCase()
        : 'PDF';

    return ResinDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: filename,
      urlOrPath: url,
      fileSize: '$sizeMb MB',
      extension: ext,
    );
  }

  Future<ResinVideo> uploadVideo({
    required Uint8List bytes,
    required String filename,
    required String title,
  }) async {
    await _ensureAuth();
    final lower = filename.toLowerCase();
    final contentType = lower.endsWith('.mov')
        ? 'video/quicktime'
        : (lower.endsWith('.m4v') ? 'video/x-m4v' : 'video/mp4');

    final url = await ApiClient.instance.uploadMediaBytes(
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );

    return ResinVideo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'GALLERY',
      urlOrPath: url,
      title: title.isNotEmpty ? title : filename,
    );
  }
}

extension ApiClientHeaders on ApiClient {
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (session.token != null) 'Authorization': 'Bearer ${session.token}',
      };
}
