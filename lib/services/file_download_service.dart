import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class FileDownloadService {
  FileDownloadService._();
  static final instance = FileDownloadService._();

  Future<void> downloadFile(
    BuildContext context, {
    required String url,
    required String filename,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Baixando $filename...',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF053488),
      ),
    );

    try {
      final downloadUrl = ApiClient.instance.mediaUrl(url);
      final response = await http
          .get(
            Uri.parse(downloadUrl),
            headers: ApiClient.instance.session.token != null
                ? {'Authorization': 'Bearer ${ApiClient.instance.session.token}'}
                : null,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final bytes = response.bodyBytes;
        String savedPath = '';

        try {
          if (Platform.isAndroid) {
            final publicDownloadDir = Directory('/storage/emulated/0/Download');
            if (publicDownloadDir.existsSync()) {
              final file = File('${publicDownloadDir.path}/$filename');
              await file.writeAsBytes(bytes);
              savedPath = file.path;
            }
          } else if (Platform.isWindows) {
            final userProfile = Platform.environment['USERPROFILE'];
            if (userProfile != null) {
              final downloadsDir = Directory('$userProfile\\Downloads');
              if (downloadsDir.existsSync()) {
                final file = File('${downloadsDir.path}\\$filename');
                await file.writeAsBytes(bytes);
                savedPath = file.path;
              }
            }
          }
        } catch (_) {}

        if (savedPath.isEmpty) {
          final tempFile = File('${Directory.systemTemp.path}/$filename');
          await tempFile.writeAsBytes(bytes);
          savedPath = tempFile.path;
        }

        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Download concluído: $filename salvo com sucesso!',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF22C55E),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        throw ApiException('Falha no download (HTTP ${response.statusCode})');
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Erro ao baixar arquivo: $e',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
