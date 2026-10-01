import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'api_client.dart';

class ChatSession {
  final String id;
  final String title;
  final String lastMessageSnippet;
  final DateTime updatedAt;
  final List<Map<String, dynamic>> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.lastMessageSnippet,
    required this.updatedAt,
    this.messages = const [],
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Conversa sem título',
      lastMessageSnippet: json['lastMessageSnippet']?.toString() ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messages: (json['messages'] as List? ?? [])
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lastMessageSnippet': lastMessageSnippet,
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages,
      };

  ChatSession copyWith({
    String? id,
    String? title,
    String? lastMessageSnippet,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessageSnippet: lastMessageSnippet ?? this.lastMessageSnippet,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}

class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._internal();
  ChatService._internal() {
    loadLocalCache();
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  final List<ChatSession> _sessions = [];
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  bool _loadedFromDisk = false;
  bool get loadedFromDisk => _loadedFromDisk;

  void _safeNotify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  File? _getCacheFile() {
    try {
      final tempDir = Directory.systemTemp;
      return File('${tempDir.path}/pext_chat_sessions.json');
    } catch (_) {
      return null;
    }
  }

  void loadLocalCache() {
    try {
      final file = _getCacheFile();
      if (file != null && file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content);
          if (decoded is List) {
            _sessions.clear();
            for (final item in decoded) {
              if (item is Map) {
                _sessions.add(ChatSession.fromJson(Map<String, dynamic>.from(item)));
              }
            }
            _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            _loadedFromDisk = true;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading chat sessions cache: $e');
    }
  }

  void _saveLocalCache() {
    try {
      final file = _getCacheFile();
      if (file != null) {
        final data = _sessions.map((s) => s.toJson()).toList();
        file.writeAsStringSync(jsonEncode(data), flush: true);
      }
    } catch (e) {
      debugPrint('Error saving chat sessions cache: $e');
    }
  }

  void setSessionsForTest(List<ChatSession> items) {
    _sessions.clear();
    _sessions.addAll(items);
    _safeNotify();
  }

  Future<void> fetchSessions() async {
    // First ensure local cache is loaded if in-memory list is empty
    if (_sessions.isEmpty && !_loadedFromDisk) {
      loadLocalCache();
      if (_sessions.isNotEmpty) {
        _safeNotify();
      }
    }

    try {
      final list = await ApiClient.instance.getChatSessions();
      _sessions.clear();
      for (final item in list) {
        _sessions.add(ChatSession.fromJson(item));
      }
      _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _saveLocalCache();
      _safeNotify();
    } catch (_) {
      // If remote fetch fails (e.g. offline), local cache remains available
      if (_sessions.isEmpty) {
        loadLocalCache();
        _safeNotify();
      }
    }
  }

  Future<void> saveSession(ChatSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _saveLocalCache();
    _safeNotify();

    try {
      await ApiClient.instance.saveChatSession(session.toJson());
    } catch (_) {}
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    _saveLocalCache();
    _safeNotify();

    try {
      await ApiClient.instance.deleteChatSession(id);
    } catch (_) {}
  }

  Future<void> clearAllSessions() async {
    final copy = List<ChatSession>.from(_sessions);
    _sessions.clear();
    _saveLocalCache();
    _safeNotify();

    for (final s in copy) {
      try {
        await ApiClient.instance.deleteChatSession(s.id);
      } catch (_) {}
    }
  }

  /// Sends a message directly to the real conversational LLM integration.
  /// Passes the ongoing conversation history to preserve session context.
  Future<Map<String, dynamic>> sendMessage(
    String message, {
    List<Map<String, dynamic>>? history,
  }) async {
    _isProcessing = true;
    _safeNotify();

    try {
      final response =
          await ApiClient.instance.askChat(message, history: history);
      return response;
    } finally {
      _isProcessing = false;
      _safeNotify();
    }
  }
}
