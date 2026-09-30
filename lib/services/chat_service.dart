import 'package:flutter/foundation.dart';
import 'api_client.dart';

class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._internal();
  ChatService._internal();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  /// Sends a message directly to the real conversational LLM integration.
  /// Passes the ongoing conversation history to preserve session context.
  Future<Map<String, dynamic>> sendMessage(
    String message, {
    List<Map<String, dynamic>>? history,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.askChat(message, history: history);
      return response;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
