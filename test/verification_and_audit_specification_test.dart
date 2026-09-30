import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/admin/admin_user_screens.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/models/content_model.dart';
import 'package:pext/models/doubt_model.dart';
import 'package:pext/services/api_client.dart';
import 'package:pext/services/favorites_service.dart';
import 'package:pext/shared/widgets/dashboard/dashboard_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Verification Parameters UI in Chat (VerificationParametersCard)', () {
    test('Strongly-typed deserialization of verificationData into VerificationParameterItem', () {
      final json = {
        'packagingId': 'RAP10 Especial',
        'parameters': [
          {
            'parameterName': 'Temperatura do cilindro',
            'target': '160.0 - 180.0 °C',
            'measuredValue': '155.0 °C',
            'deviation': '-5.0 °C',
          },
          {
            'parameterName': 'Velocidade da linha',
            'target': '20.0 - 30.0 m/min',
            'measuredValue': '25.0 m/min',
            'deviation': '0.0 m/min',
          },
        ],
      };

      const doubt = DoubtModel(
        id: 'd1',
        userId: 'u1',
        userName: 'Operador Teste',
        question: 'Problema reportado: Bolhas no filme',
        createdAt: '30/09/2026',
        verificationData: {
          'packagingId': 'RAP10 Especial',
          'parameters': [
            {
              'parameterName': 'Temperatura do cilindro',
              'target': '160.0 - 180.0 °C',
              'measuredValue': '155.0 °C',
              'deviation': '-5.0 °C',
            },
            {
              'parameterName': 'Velocidade da linha',
              'target': '20.0 - 30.0 m/min',
              'measuredValue': '25.0 m/min',
              'deviation': '0.0 m/min',
            },
          ],
        },
      );

      final params = doubt.parsedVerificationParameters;
      expect(params.length, 2);
      expect(doubt.targetPackagingName, 'RAP10 Especial');

      // Check first parameter (out of range)
      expect(params[0].parameterName, 'Temperatura do cilindro');
      expect(params[0].target, '160.0 - 180.0 °C');
      expect(params[0].measuredValue, '155.0 °C');
      expect(params[0].deviation, '-5.0 °C');
      expect(params[0].isWithinRange, isFalse);

      // Check second parameter (within range)
      expect(params[1].parameterName, 'Velocidade da linha');
      expect(params[1].target, '20.0 - 30.0 m/min');
      expect(params[1].measuredValue, '25.0 m/min');
      expect(params[1].deviation, '0.0 m/min');
      expect(params[1].isWithinRange, isTrue);
    });

    testWidgets('Renders VerificationParametersCard with header, packaging pill, and color badges',
        (tester) async {
      const doubt = DoubtModel(
        id: 'd2',
        userId: 'u1',
        userName: 'Operador Teste',
        question: 'Instabilidade na espessura do filme',
        createdAt: '30/09/2026',
        verificationData: {
          'packagingId': 'Teste Standup',
          'parameters': [
            {
              'parameterName': 'Temperatura do cilindro',
              'target': '160.0 - 180.0 °C',
              'measuredValue': '1.0 °C',
              'deviation': '-169.0 °C',
            },
            {
              'parameterName': 'Pressão do sistema',
              'target': '70.0 - 90.0 bar',
              'measuredValue': '80.0 bar',
              'deviation': '0.0 bar',
            },
          ],
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DoubtThreadScreen(doubt: doubt, admin: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Card Header
      expect(find.text('Parâmetros de Verificação'), findsOneWidget);
      expect(find.text('Embalagem: Teste Standup'), findsOneWidget);

      // Check Rows
      expect(find.text('Temperatura do cilindro'), findsOneWidget);
      expect(find.textContaining('Alvo: 160.0 - 180.0 °C'), findsOneWidget);
      expect(find.textContaining('Lido: 1.0 °C'), findsOneWidget);
      expect(find.textContaining('-169.0 °C'), findsOneWidget);

      expect(find.text('Pressão do sistema'), findsOneWidget);
      expect(find.textContaining('Alvo: 70.0 - 90.0 bar'), findsOneWidget);
      expect(find.textContaining('Lido: 80.0 bar'), findsOneWidget);
      expect(find.textContaining('Desvio: 0.0 bar'), findsOneWidget);

      // Check separated clean problem block
      expect(find.textContaining('Problema reportado: Instabilidade na espessura do filme'), findsOneWidget);
    });
  });

  group('2. Terms Dictionary: Silent & Optimistic Favorites', () {
    testWidgets('Toggling term favorite updates state optimistically without SnackBar toasts',
        (tester) async {
      FavoritesService.instance.setFavoritesForTest(
        ids: {},
        terms: [],
        trainings: [],
      );

      const term = ApiContent({
        'id': 'term-42',
        'term': 'Coextrusão',
        'definition': 'Processo de múltiplas camadas',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DetalhesTermoScreen(item: term, admin: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the favorite icon button
      final favButton = find.byIcon(Icons.favorite_border);
      expect(favButton, findsOneWidget);

      // Tap to favorite
      await tester.tap(favButton);
      await tester.pump();

      // Verify optimistic update took place immediately
      expect(FavoritesService.instance.isFavorite('term-42'), isTrue);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Ensure NO SnackBar was triggered (silent action)
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('3. Content Versioning: Point-to-Point Audit Snapshots', () {
    test('ContentAuditEntry serializes and deserializes previous and new file snapshots', () {
      final entry = ContentAuditEntry.fromJson({
        'id': 'audit-1',
        'authorName': 'Maria',
        'authorRole': 'ADMIN',
        'action': 'UPDATE',
        'date': '02/08/2026 - 09:43',
        'title': 'Maria editou o conteúdo',
        'description': 'Alterações:\n- Inclusão de Documento',
        'previousContent': {
          'title': 'Material irregular na matriz',
          'text': 'Versão 1',
          'documentName': null,
          'documentUrl': null,
          'date': '01/08/2026 - 09:33',
        },
        'newContent': {
          'title': 'Material irregular na matriz',
          'text': 'Versão 2',
          'documentName': 'Ficha_v2.pdf',
          'documentUrl': '/uploads/ficha_v2.pdf',
          'date': '02/08/2026 - 09:43',
        },
      });

      expect(entry.previousFileSnapshot, isNotNull);
      expect(entry.previousFileSnapshot!['documentName'], isNull);
      expect(entry.newFileSnapshot, isNotNull);
      expect(entry.newFileSnapshot!['documentName'], 'Ficha_v2.pdf');
    });

    testWidgets('ComparacaoVersoesConteudoScreen compares point-to-point revision snapshots strictly',
        (tester) async {
      final prevSnapshot = {
        'text': 'Procedimento anterior v1',
        'documentName': 'Ficha_v1.pdf',
        'documentUrl': 'http://example.com/v1.pdf',
        'date': '01/08/2026 - 09:00',
      };

      final newSnapshot = {
        'text': 'Procedimento novo v2',
        'documentName': 'Ficha_v2.pdf',
        'documentUrl': 'http://example.com/v2.pdf',
        'date': '05/08/2026 - 10:00',
      };

      // Current document on content is v3, but screen must read strictly from the audit snapshot (v1 -> v2)
      final content = ContentModel(
        id: 'c-100',
        title: 'Guia de Coextrusão',
        text: 'Procedimento v3',
        authorName: 'Carlos',
        createdAt: '01/08/2026',
        updatedAt: '10/08/2026',
        documentName: 'Ficha_v3.pdf',
        documentUrl: 'http://example.com/v3.pdf',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComparacaoVersoesConteudoScreen(
              currentContent: content,
              previousSnapshot: prevSnapshot,
              newSnapshot: newSnapshot,
              author: 'Maria',
              date: '05/08/2026 - 10:00',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Read strictly from snapshot texts
      expect(find.text('Procedimento anterior v1'), findsOneWidget);
      expect(find.text('Procedimento novo v2'), findsOneWidget);

      // Read strictly from snapshot attachments
      expect(find.text('Ficha_v1.pdf'), findsOneWidget);
      expect(find.text('Ficha_v2.pdf'), findsOneWidget);
      expect(find.text('Ficha_v3.pdf'), findsNothing);
    });
  });

  group('4. Admin User Management: Assessment Analytics & Course Status Breakdown', () {
    testWidgets('AdminUserDetailScreen renders status chart, KPI cards, assessment badges and attempts counter',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final userData = {
        'id': 'usr-admin-1',
        'name': 'Ana Silva',
        'email': 'ana@pext.ind.br',
        'cargo': 'Operadora Líder',
        'role': 'USER',
        'assessmentAnalytics': {
          'accuracyRate': 85.0,
          'averageAttemptsToPass': 1.5,
        },
        'enrolledTrainings': [
          {
            'id': 't1',
            'title': 'Segurança na Coextrusão',
            'status': 'Concluído',
            'progressPercentage': 100,
            'completedModules': 4,
            'totalModules': 4,
            'score': 90,
            'passingGrade': 70,
            'assessmentStatus': 'Aprovado',
            'attempts': 1,
            'correctQuestions': 9,
            'totalQuestions': 10,
          },
          {
            'id': 't2',
            'title': 'Troca de Matriz Avançada',
            'status': 'Em andamento',
            'progressPercentage': 100,
            'completedModules': 3,
            'totalModules': 3,
            'score': null,
            'passingGrade': 70,
            'assessmentStatus': 'Pendente',
            'attempts': 0,
            'correctQuestions': 0,
            'totalQuestions': 10,
          },
          {
            'id': 't3',
            'title': 'Calibração de Temperatura',
            'status': 'Desistência',
            'progressPercentage': 30,
            'completedModules': 1,
            'totalModules': 3,
            'score': 50,
            'passingGrade': 70,
            'assessmentStatus': 'Reprovado',
            'attempts': 2,
            'correctQuestions': 5,
            'totalQuestions': 10,
          },
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdminUserDetailScreen(
              userId: 'usr-admin-1',
              initialData: userData,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Section Headers
      expect(find.text('Treinamentos Matriculados (3)'), findsOneWidget);
      expect(find.text('Desempenho e Avaliações'), findsOneWidget);

      // Check KPI Cards
      expect(find.text('Taxa de Acerto Geral'), findsOneWidget);
      expect(find.text('Média de Tentativas'), findsOneWidget);

      // Check Status Donut Chart
      expect(find.byType(DonutChartCard), findsOneWidget);
      expect(find.text('Status dos Treinamentos'), findsOneWidget);

      // Check Course Cards
      expect(find.text('Segurança na Coextrusão'), findsOneWidget);
      expect(find.text('Aprovado'), findsOneWidget);
      expect(find.text('Tentativas: 1'), findsOneWidget);

      expect(find.text('Troca de Matriz Avançada'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('Tentativas: 0'), findsOneWidget);

      expect(find.text('Calibração de Temperatura'), findsOneWidget);
      expect(find.text('Reprovado'), findsOneWidget);
      expect(find.text('Tentativas: 2'), findsOneWidget);
    });
  });
}
