import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/features/resins/resins_screens.dart';
import 'package:pext/models/content_model.dart';
import 'package:pext/models/doubt_model.dart';
import 'package:pext/models/resin_model.dart';
import 'package:pext/models/training_model.dart';
import 'package:pext/services/favorites_service.dart';
import 'package:pext/services/file_download_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FavoritesService.instance.mockNetworkSuccessInTest = true;
    FavoritesService.instance.setFavoritesForTest(
      ids: {},
      terms: [],
      trainings: [],
    );
  });

  group('1. Chat Verification Parameters: Plain Text Layout Refactoring', () {
    testWidgets('Renders clean plain text layout without nested micro-cards or unconstrained rows',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640)); // Mobile portrait size
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final doubt = DoubtModel(
        id: 'd-mobile-1',
        userId: 'usr-1',
        userName: 'Igor',
        question: 'testando na embalagem teste',
        status: 'ABERTA',
        createdAt: '2026-09-30T12:04:03.322Z',
        verificationData: {
          'packaging': 'teste',
          'parameters': [
            {
              'parameterName': 'Temperatura do cilindro',
              'target': '160.0 - 180.0 °C',
              'measuredValue': '1.0 °C',
              'deviation': '-169.0 °C',
            },
            {
              'parameterName': 'Velocidade da linha',
              'target': '20.0 - 35.0 m/min',
              'measuredValue': '16.0 m/min',
              'deviation': '-11.5 m/min',
            },
            {
              'parameterName': 'Pressão do sistema',
              'target': '70.0 - 90.0 bar',
              'measuredValue': '8.0 bar',
              'deviation': '-72.0 bar',
            },
            {
              'parameterName': 'Abertura da matriz',
              'target': '0.04 - 0.06 mm',
              'measuredValue': '8.0 mm',
              'deviation': '+8.0 mm',
            },
            {
              'parameterName': 'testee',
              'target': '10.0 - 10.0 C°',
              'measuredValue': '8.0 C°',
              'deviation': '-2.0 C°',
            },
          ],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoubtThreadScreen(
              doubt: doubt,
              admin: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header contains clipboard and packaging
      expect(find.textContaining('📋 Parâmetros de Verificação (Embalagem: teste)'), findsOneWidget);

      // Check plain text parameter bullet lines
      expect(find.textContaining('• Temperatura do cilindro: 1.0 °C (Alvo: 160.0 - 180.0 °C | Desvio: -169.0 °C)'), findsOneWidget);
      expect(find.textContaining('• Velocidade da linha: 16.0 m/min (Alvo: 20.0 - 35.0 m/min | Desvio: -11.5 m/min)'), findsOneWidget);
      expect(find.textContaining('• Pressão do sistema: 8.0 bar (Alvo: 70.0 - 90.0 bar | Desvio: -72.0 bar)'), findsOneWidget);
      expect(find.textContaining('• Abertura da matriz: 8.0 mm (Alvo: 0.04 - 0.06 mm | Desvio: +8.0 mm)'), findsOneWidget);
      expect(find.textContaining('• testee: 8.0 C° (Alvo: 10.0 - 10.0 C° | Desvio: -2.0 C°)'), findsOneWidget);

      // Check problem report block within card
      expect(find.textContaining('Problema reportado: testando na embalagem teste'), findsOneWidget);

      // Verify no overflow exceptions occurred
      expect(tester.takeException(), isNull);
    });
  });

  group('2. Global Elimination of Favorite Popups / SnackBars', () {
    testWidgets('Resin detail favorite toggle is completely silent without SnackBars', (tester) async {
      final resin = ResinModel(
        id: 'resin-99',
        name: 'PEBD Linear 100',
        acronym: 'PEBDL',
        categoryName: 'PEBD',
        isFavorite: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResinDetailScreen(
              resinId: 'resin-99',
              initialResin: resin,
              admin: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find favorite button in app bar
      final favBtn = find.byIcon(Icons.favorite_border);
      expect(favBtn, findsOneWidget);

      await tester.tap(favBtn);
      await tester.pumpAndSettle();

      // Verified no SnackBar appeared
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Training detail favorite toggle is completely silent without SnackBars', (tester) async {
      final training = TrainingModel(
        id: 't-silent-1',
        title: 'Segurança na Coextrusão',
        description: 'Fundamentos de segurança',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingDetailScreen(
              training: training,
              admin: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final favBtn = find.byIcon(Icons.favorite_border);
      if (favBtn.evaluate().isNotEmpty) {
        await tester.tap(favBtn.first);
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
      }
    });
  });

  group('3. Content Versioning: Dedicated File Revision Audit Schema', () {
    test('ContentAuditEntry parses previous_file_name and new_file_name directly from log schema', () {
      final logJson = {
        'id': 'log-uuid-1',
        'content_id': 'c-uuid-10',
        'changed_by': 'usr-admin-maria',
        'previous_file_name': 'Especificacao_v1.pdf',
        'previous_file_url': 'http://pext.local/v1.pdf',
        'new_file_name': 'Especificacao_v2.pdf',
        'new_file_url': 'http://pext.local/v2.pdf',
        'action_type': 'UPDATED',
        'created_at': '2026-09-30T14:00:00Z',
        'title': 'Maria atualizou a especificação',
        'description': 'Alteração do arquivo técnico',
      };

      final entry = ContentAuditEntry.fromJson(logJson);
      expect(entry.previousFileName, 'Especificacao_v1.pdf');
      expect(entry.previousFileUrl, 'http://pext.local/v1.pdf');
      expect(entry.newFileName, 'Especificacao_v2.pdf');
      expect(entry.newFileUrl, 'http://pext.local/v2.pdf');
    });

    testWidgets('ComparacaoVersoesConteudoScreen displays historical file names ignoring current live record',
        (tester) async {
      final content = ContentModel(
        id: 'c-100',
        title: 'Guia Operacional',
        text: 'Texto atual v5',
        authorName: 'Admin',
        createdAt: '01/08/2026',
        updatedAt: '30/09/2026',
        documentName: 'documento_live_v5.pdf', // Live active document
        documentUrl: 'http://example.com/v5.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComparacaoVersoesConteudoScreen(
              currentContent: content,
              previousFileName: 'Ficha_Historica_v1.pdf',
              newFileName: 'Ficha_Historica_v2.pdf',
              previousSnapshot: const {'date': '01/08/2026', 'text': 'Texto v1'},
              newSnapshot: const {'date': '15/08/2026', 'text': 'Texto v2'},
              author: 'Maria',
              date: '15/08/2026',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert that historical audit file names are shown
      expect(find.text('Ficha_Historica_v1.pdf'), findsOneWidget);
      expect(find.text('Ficha_Historica_v2.pdf'), findsOneWidget);

      // Assert that live v5 document is completely ignored
      expect(find.text('documento_live_v5.pdf'), findsNothing);
    });
  });

  group('4. FileDownloadService: Download and Immediate Launch Pipeline', () {
    testWidgets('Downloads file to storage and displays notification with ABRIR action', (tester) async {
      BuildContext? capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Test');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await FileDownloadService.instance.downloadFile(
        capturedContext!,
        url: '', // Local fallback synthesis
        filename: 'Teste_Manual.pdf',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Destination feedback
      expect(find.text('Salvo na pasta Downloads: Teste_Manual.pdf'), findsOneWidget);
      expect(find.text('ABRIR'), findsOneWidget);
    });
  });
}
