import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_category.dart';
import '../models/packaging_specification.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiSession {
  String? token;
  String? userId;
  String? role;
  String? name;
  String? email;
  String? avatarUrl;
  String? cargo;
  bool get isAdmin => role == 'ADMIN';
  void clear() {
    token = null;
    userId = null;
    role = null;
    name = null;
    email = null;
    avatarUrl = null;
    cargo = null;
  }
}

class ApiProblem {
  final String id;
  final String title;
  final String description;
  final String recommendedSolution;
  final String? categoryId;
  const ApiProblem(
      {required this.id,
      required this.title,
      required this.description,
      required this.recommendedSolution,
      this.categoryId});
  factory ApiProblem.fromJson(Map<String, dynamic> json) => ApiProblem(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      recommendedSolution: json['recommendedSolution']?.toString() ?? '',
      categoryId: json['categoryId']?.toString());
}

class ApiContent {
  final Map<String, dynamic> data;
  const ApiContent(this.data);
  String get id => data['id']?.toString() ?? '';
  String text(String key) => data[key]?.toString() ?? '';
  int? intVal(String key) => (data[key] as num?)?.toInt() ?? int.tryParse(data[key]?.toString() ?? '');
  List<String> strings(String key) => List<String>.from(
      (data[key] as List? ?? const []).map((item) => item.toString()));
}

class ApiClient {
  ApiClient._();
  static final instance = ApiClient._();
  static String _activeBaseUrl = '';

  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (_activeBaseUrl.isNotEmpty) return _activeBaseUrl;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return 'http://127.0.0.1:3000/api/v1';
    }
    // Physical Android devices use `adb reverse tcp:3000 tcp:3000` during
    // local development, so localhost is routed to the computer's API.
    // Emulators can still use 10.0.2.2 through API_BASE_URL when needed.
    return 'http://127.0.0.1:3000/api/v1';
  }

  static void setBaseUrl(String url) {
    _activeBaseUrl = url;
  }

  final session = ApiSession();
  String get mediaOrigin {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  String mediaUrl(String? value) {
    if (value == null || value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('assets/') || value.startsWith('images/') || value.startsWith('icons/')) {
      return value;
    }
    final normalized = value.startsWith('/') ? value : '/$value';
    return '$mediaOrigin$normalized';
  }

  String resolveMediaUrl(String? value) => mediaUrl(value);

  Future<bool> login(String email, String password) async {
    final candidates = <String>[];
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      candidates.add(configured);
    } else {
      if (_activeBaseUrl.isNotEmpty) candidates.add(_activeBaseUrl);
      candidates.add('http://127.0.0.1:3000/api/v1');
      candidates.add('http://100.94.91.23:3000/api/v1');
      candidates.add('http://192.168.100.170:3000/api/v1');
      candidates.add('http://10.0.2.2:3000/api/v1');
    }

    Object? lastError;
    for (final base in candidates.toSet()) {
      try {
        final response = await http
            .post(Uri.parse('$base/auth/login'),
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode({'email': email, 'password': password}))
            .timeout(const Duration(milliseconds: 3000));
        final payload = _payload(response);
        _activeBaseUrl = base;
        session.token = payload['token']?.toString();
        final user = Map<String, dynamic>.from(payload['user'] as Map? ?? {});
        session.userId = user['id']?.toString();
        session.role = user['role']?.toString();
        session.name = user['name']?.toString();
        session.email = user['email']?.toString();
        session.avatarUrl = user['avatarUrl']?.toString();
        session.cargo = user['cargo']?.toString();
        return session.token != null;
      } on ApiException {
        _activeBaseUrl = base;
        rethrow;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? ApiException('Could not reach backend.');
  }

  Future<List<PackagingSpecification>> packagings() async {
    final payload = _payload(await _get('/packagings'));
    final items = List<Map<String, dynamic>>.from(
        (payload['items'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map)));
    return items.map(PackagingSpecification.fromJson).toList(growable: true);
  }

  Future<List<ApiProblem>> problems({String? query}) async {
    final suffix = query == null || query.isEmpty
        ? ''
        : '?q=${Uri.encodeQueryComponent(query)}';
    final payload = _payload(await _get('/problems$suffix'));
    final items = List<Map<String, dynamic>>.from(
        (payload['items'] as List? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map)));
    return items.map(ApiProblem.fromJson).toList(growable: true);
  }

  Future<List<ApiContent>> content(String endpoint, {String? query}) async {
    final suffix = query == null || query.isEmpty
        ? ''
        : '?q=${Uri.encodeQueryComponent(query)}';
    final payload = _payload(await _get('/$endpoint$suffix'));
    return List<Map<String, dynamic>>.from(
            (payload['items'] as List? ?? const [])
                .map((item) => Map<String, dynamic>.from(item as Map)))
        .map(ApiContent.new)
        .toList(growable: true);
  }

  Future<ApiContent> contentRecord(String endpoint, String id) async {
    final payload = _payload(await _get('/$endpoint/$id'));
    return ApiContent(payload);
  }

  Future<ApiContent> createContent(
      String endpoint, Map<String, dynamic> values) async {
    final response = await http
        .post(Uri.parse('$baseUrl/$endpoint'),
            headers: _headers, body: jsonEncode(values))
        .timeout(const Duration(seconds: 10));
    return ApiContent(_payload(response));
  }

  Future<ApiContent> updateContent(
      String endpoint, String id, Map<String, dynamic> values) async {
    final response = await http
        .put(Uri.parse('$baseUrl/$endpoint/$id'),
            headers: _headers, body: jsonEncode(values))
        .timeout(const Duration(seconds: 10));
    return ApiContent(_payload(response));
  }

  Future<void> deleteContent(String endpoint, String id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/$endpoint/$id'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    _payload(response);
  }

  Future<List<AppCategory>> categories(CategoryScope scope) async {
    final payload = _payload(await _get(
        '/categories?scope=${Uri.encodeQueryComponent(scope.value)}'));
    return List<Map<String, dynamic>>.from(
            (payload['items'] as List? ?? const [])
                .map((item) => Map<String, dynamic>.from(item as Map)))
        .map(AppCategory.fromJson)
        .toList(growable: true);
  }

  Future<AppCategory> createCategory(String name, CategoryScope scope,
      {String? imageUrl, String? iconKey}) async {
    final response = await http
        .post(Uri.parse('$baseUrl/categories'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'scope': scope.value,
              if (imageUrl != null) 'imageUrl': imageUrl,
              if (iconKey != null) 'iconKey': iconKey,
            }))
        .timeout(const Duration(seconds: 10));
    return AppCategory.fromJson(_payload(response));
  }

  Future<AppCategory> updateCategory(String id, String name,
      {String? imageUrl, String? iconKey}) async {
    final response = await http
        .put(Uri.parse('$baseUrl/categories/$id'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              if (imageUrl != null) 'imageUrl': imageUrl,
              if (iconKey != null) 'iconKey': iconKey,
            }))
        .timeout(const Duration(seconds: 10));
    return AppCategory.fromJson(_payload(response));
  }

  Future<void> deleteCategory(String id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/categories/$id'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    _payload(response);
  }

  Future<String> uploadImage(XFile file) async {
    final extension = file.name.contains('.')
        ? file.name.substring(file.name.lastIndexOf('.')).toLowerCase()
        : '';
    const contentTypes = <String, String>{
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
    };
    final contentType = contentTypes[extension];
    if (contentType == null) {
      throw ApiException('Select a PNG or JPEG image.');
    }
    final bytes = await file.readAsBytes();
    return uploadMediaBytes(
        bytes: bytes, filename: file.name, contentType: contentType);
  }

  Future<String> uploadMediaBytes({
    required Uint8List bytes,
    required String filename,
    required String contentType,
  }) async {
    if (bytes.isEmpty) {
      throw ApiException('The selected file is empty. Choose another file.');
    }
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/media'))
      ..headers.addAll(_headers)
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: filename, contentType: MediaType.parse(contentType)));
    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    return _payload(response)['url']?.toString() ?? '';
  }

  Future<PackagingSpecification> createPackaging(
      PackagingSpecification packaging,
      {String? category,
      String? categoryId,
      String? imageUrl}) async {
    final effectiveCategoryId = categoryId ?? packaging.categoryId;
    final effectiveCategory =
        category ?? packaging.categoryName ?? packaging.category;
    final response = await http
        .post(Uri.parse('$baseUrl/packagings'),
            headers: _headers,
            body: jsonEncode({
              'name': packaging.name,
              'category': effectiveCategory,
              if (effectiveCategoryId != null)
                'categoryId': effectiveCategoryId,
              'imageUrl': imageUrl ?? packaging.imageUrl,
              'parameters': packaging.allParameters
                  .map((parameter) => parameter.toApiJson())
                  .toList(),
            }))
        .timeout(const Duration(seconds: 10));
    return PackagingSpecification.fromJson(_payload(response));
  }

  Future<PackagingSpecification> updatePackaging(
      String id, PackagingSpecification packaging,
      {String? category, String? categoryId, String? imageUrl}) async {
    final effectiveCategoryId = categoryId ?? packaging.categoryId;
    final effectiveCategory =
        category ?? packaging.categoryName ?? packaging.category;
    final response = await http
        .put(Uri.parse('$baseUrl/packagings/$id'),
            headers: _headers,
            body: jsonEncode({
              'name': packaging.name,
              'category': effectiveCategory,
              if (effectiveCategoryId != null)
                'categoryId': effectiveCategoryId,
              'imageUrl': imageUrl ?? packaging.imageUrl,
              'parameters': packaging.allParameters
                  .map((parameter) => parameter.toApiJson())
                  .toList(),
            }))
        .timeout(const Duration(seconds: 10));
    return PackagingSpecification.fromJson(_payload(response));
  }

  Future<void> deletePackaging(String id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/packagings/$id'), headers: _headers)
        .timeout(const Duration(seconds: 10));
    _payload(response);
  }

  Future<Map<String, dynamic>> diagnose(
      {required String problemId,
      required String packagingId,
      required Map<String, double> inputValues}) async {
    final response = await http
        .post(Uri.parse('$baseUrl/problems/diagnose'),
            headers: _headers,
            body: jsonEncode({
              'problemId': problemId,
              'packagingId': packagingId,
              'inputValues': inputValues
            }))
        .timeout(const Duration(seconds: 10));
    return _payload(response);
  }

  Future<Map<String, dynamic>> resolveProblemBySystem(
      String diagnosticLogId) async {
    final response = await http
        .patch(
            Uri.parse(
                '$baseUrl/problems/logs/$diagnosticLogId/resolve-system'),
            headers: _headers)
        .timeout(const Duration(seconds: 10));
    return _payload(response);
  }

  Future<Map<String, dynamic>> getRaw(String path) async {
    final response = await _get(path);
    return _payload(response);
  }

  Future<Map<String, dynamic>> postRaw(
      String path, Map<String, dynamic> body) async {
    final response = await http
        .post(Uri.parse('$baseUrl$path'),
            headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _payload(response);
  }

  Future<Map<String, dynamic>> putRaw(
      String path, Map<String, dynamic> body) async {
    final response = await http
        .put(Uri.parse('$baseUrl$path'),
            headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _payload(response);
  }

  Future<void> deleteRaw(String path) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    _payload(response);
  }

  Future<Map<String, dynamic>> askChat(String query,
      {List<Map<String, dynamic>>? history}) async {
    final response = await http
        .post(Uri.parse('$baseUrl/chat'),
            headers: _headers,
            body: jsonEncode({
              'query': query,
              if (history != null && history.isNotEmpty) 'history': history,
            }))
        .timeout(const Duration(seconds: 40));
    return _payload(response);
  }

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    String? cargo,
    String role = 'USER',
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/admin/users'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            if (cargo != null) 'cargo': cargo,
            'role': role,
          }),
        )
        .timeout(const Duration(seconds: 10));
    return _payload(response);
  }

  Future<String> uploadProfileAvatar(XFile file) async {
    final uri = Uri.parse('$baseUrl/profile/avatar');
    final request = http.MultipartRequest('POST', uri);
    if (session.token != null) {
      request.headers['Authorization'] = 'Bearer ${session.token}';
    }
    final bytes = await file.readAsBytes();
    final filename = file.name.isNotEmpty ? file.name : 'avatar.jpg';
    final mimeType = filename.toLowerCase().endsWith('.png')
        ? MediaType('image', 'png')
        : MediaType('image', 'jpeg');
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: mimeType,
    ));
    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamedResponse);
    final payload = _payload(response);
    final avatarUrl = payload['avatarUrl']?.toString() ?? '';
    if (avatarUrl.isNotEmpty) {
      session.avatarUrl = avatarUrl;
    }
    return avatarUrl;
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _get('/profile/me');
    final payload = _payload(response);
    if (payload['user'] is Map) {
      final u = Map<String, dynamic>.from(payload['user'] as Map);
      session.name = u['name']?.toString() ?? session.name;
      session.email = u['email']?.toString() ?? session.email;
      session.role = u['role']?.toString() ?? session.role;
      session.avatarUrl = u['avatarUrl']?.toString() ?? session.avatarUrl;
      session.cargo = u['cargo']?.toString() ?? session.cargo;
    }
    return payload;
  }

  Future<Map<String, dynamic>> getFavorites() async {
    return getRaw('/favorites');
  }

  Future<Map<String, dynamic>> toggleFavorite({
    required String entityType,
    required String entityId,
  }) async {
    return postRaw('/favorites/toggle', {
      'entityType': entityType,
      'entityId': entityId,
    });
  }

  Future<Map<String, dynamic>> enrollTraining(String trainingId) async {
    return postRaw('/trainings/$trainingId/enroll', {});
  }

  Future<void> unenrollTraining(String trainingId) async {
    await deleteRaw('/trainings/$trainingId/unenroll');
  }

  Future<List<Map<String, dynamic>>> getChatSessions() async {
    try {
      final res = await getRaw('/chat/sessions');
      final items = res['items'] as List? ?? [];
      return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> saveChatSession(Map<String, dynamic> session) async {
    return postRaw('/chat/sessions', session);
  }

  Future<void> deleteChatSession(String id) async {
    await deleteRaw('/chat/sessions/$id');
  }

  Future<Map<String, dynamic>> createSupportTicket({
    required String description,
    String? machineId,
    String? processContext,
    Map<String, dynamic>? verificationData,
  }) async {
    return postRaw('/doubts', {
      'description': description,
      'issueDescription': description,
      'question': description,
      'machineId': machineId ?? 'Extrusora Principal',
      'processContext': processContext ?? 'Linha de Coextrusão',
      'status': 'OPEN',
      'timestamp': DateTime.now().toIso8601String(),
      if (verificationData != null) 'verificationData': verificationData,
    });
  }

  Future<Map<String, dynamic>> completeTrainingModule(
      String trainingId, String moduleId) async {
    return postRaw('/trainings/$trainingId/modules/$moduleId/complete', {});
  }

  Future<Map<String, dynamic>> submitAssessment(
    String trainingId, {
    int? score,
    int? correctCount,
    int? totalCount,
    List<Map<String, dynamic>>? answers,
    List<String>? wrongModuleIds,
  }) async {
    return postRaw('/trainings/$trainingId/assessment/submit', {
      if (score != null) 'score': score,
      if (score != null) 'scorePercentage': score,
      if (correctCount != null) 'correctCount': correctCount,
      if (totalCount != null) 'totalCount': totalCount,
      if (answers != null) 'answers': answers,
      if (wrongModuleIds != null) 'wrongModuleIds': wrongModuleIds,
    });
  }

  Future<Map<String, dynamic>> getTrainingDetail(String trainingId) async {
    return getRaw('/trainings/$trainingId');
  }

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final res = await getRaw('/admin/users');
    final items = res['items'] as List? ?? [];
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>> getAdminUserDetail(String id) async {
    return getRaw('/admin/users/$id');
  }

  Future<Map<String, dynamic>> createAdminUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? cargo,
    String role = 'USER',
  }) async {
    return postRaw('/admin/users', {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (cargo != null) 'cargo': cargo,
      'role': role,
    });
  }

  Future<Map<String, dynamic>> updateAdminUser(
    String id, {
    String? name,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? cargo,
    String? role,
  }) async {
    return putRaw('/admin/users/$id', {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null && password.isNotEmpty) 'password': password,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (cargo != null) 'cargo': cargo,
      if (role != null) 'role': role,
    });
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return postRaw('/auth/forgot-password', {'email': email});
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return postRaw('/auth/reset-password', {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<Map<String, dynamic>> getTrainingAnalytics() async {
    return getRaw('/dashboard/stats');
  }

  Future<Map<String, dynamic>> getAnalytics(String subResource, {String period = '30d'}) async {
    return getRaw('/analytics/$subResource?period=$period');
  }

  Future<Map<String, dynamic>> getFullDashboardAnalytics({String period = '30d'}) async {
    return getRaw('/analytics/all?period=$period');
  }

  Future<http.Response> _get(String path) => http
      .get(Uri.parse('$baseUrl$path'), headers: _headers)
      .timeout(const Duration(seconds: 10));
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (session.token != null) 'Authorization': 'Bearer ${session.token}',
      };
  Map<String, dynamic> _payload(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['error'] != null) {
            throw ApiException(decoded['error'].toString());
          }
        } catch (e) {
          if (e is ApiException) rethrow;
        }
      }
      throw ApiException(
          'Unable to contact the API (status ${response.statusCode}).');
    }
    if (response.body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return {'items': decoded};
    }
    return Map<String, dynamic>.from(decoded as Map);
  }
}

