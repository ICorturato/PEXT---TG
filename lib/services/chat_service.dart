import 'package:flutter/foundation.dart';
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
  ChatService._internal();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  final List<ChatSession> _sessions = [];
  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  Future<void> fetchSessions() async {
    try {
      final list = await ApiClient.instance.getChatSessions();
      _sessions.clear();
      for (final item in list) {
        _sessions.add(ChatSession.fromJson(item));
      }
      _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> saveSession(ChatSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();

    try {
      await ApiClient.instance.saveChatSession(session.toJson());
    } catch (_) {}
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    notifyListeners();

    try {
      await ApiClient.instance.deleteChatSession(id);
    } catch (_) {}
  }

  Future<void> clearAllSessions() async {
    final copy = List<ChatSession>.from(_sessions);
    _sessions.clear();
    notifyListeners();

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
    notifyListeners();

    try {
      final response =
          await ApiClient.instance.askChat(message, history: history);
      return response;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
