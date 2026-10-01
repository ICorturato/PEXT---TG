import 'package:flutter/foundation.dart';

import '../models/doubt_model.dart';
import 'api_client.dart';

class DoubtService extends ChangeNotifier {
  static final DoubtService instance = DoubtService._internal();
  DoubtService._internal();

  final List<DoubtModel> _doubts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DoubtModel> get doubts => List.unmodifiable(_doubts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setDoubtsForTest(List<DoubtModel> items) {
    _doubts.clear();
    _doubts.addAll(items);
    notifyListeners();
  }

  Future<List<DoubtModel>> fetchDoubts({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final suffix = status != null && status.isNotEmpty
          ? '?status=${Uri.encodeQueryComponent(status)}'
          : '';
      final payload = await ApiClient.instance.getRaw('/doubts$suffix');
      final items = List<Map<String, dynamic>>.from(
          (payload['items'] as List? ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map)));

      _doubts.clear();
      for (final item in items) {
        _doubts.add(DoubtModel.fromJson(item));
      }
      _isLoading = false;
      notifyListeners();
      return _doubts;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return _doubts;
    }
  }

  Future<DoubtModel> createDoubt(String question) async {
    final payload = await ApiClient.instance.postRaw('/doubts', {
      'question': question,
    });
    final created = DoubtModel.fromJson(payload);
    _doubts.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<DoubtMessage> replyDoubt(String doubtId, String text) async {
    final payload =
        await ApiClient.instance.postRaw('/doubts/$doubtId/messages', {
      'text': text,
    });
    final message = DoubtMessage.fromJson(payload);
    final index = _doubts.indexWhere((d) => d.id == doubtId);
    if (index != -1) {
      final current = _doubts[index];
      final updatedMsgs = List<DoubtMessage>.from(current.messages)..add(message);
      // Reopen or move to IN_PROGRESS
      final newStatus = 'IN_PROGRESS';
      _doubts[index] = current.copyWith(
        messages: updatedMsgs,
        status: newStatus,
      );
      notifyListeners();
    }
    return message;
  }

  Future<DoubtModel> resolveDoubt(String doubtId) => finalizeDoubt(doubtId);

  Future<DoubtModel> finalizeDoubt(String doubtId) async {
    final payload = await ApiClient.instance.postRaw('/doubts/$doubtId/finalize', {});
    final doubtData = payload['doubt'] != null && payload['doubt'] is Map
        ? Map<String, dynamic>.from(payload['doubt'] as Map)
        : null;
    final updatedModel = doubtData != null ? DoubtModel.fromJson(doubtData) : null;
    final index = _doubts.indexWhere((d) => d.id == doubtId);
    if (index != -1) {
      _doubts[index] = updatedModel ?? _doubts[index].copyWith(status: 'FINALIZADO');
      notifyListeners();
      return _doubts[index];
    }
    return updatedModel ?? DoubtModel.fromJson(payload);
  }

  Future<Map<String, dynamic>> askChat(String query) async {
    return await ApiClient.instance.askChat(query);
  }
}
