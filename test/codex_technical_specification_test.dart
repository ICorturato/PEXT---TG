import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/models/content_model.dart';
import 'package:pext/models/doubt_model.dart';
import 'package:pext/models/training_model.dart';
import 'package:pext/services/favorites_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Codex Technical Specification Tests', () {
    test('Universal FavoritesService state synchronization', () {
      final service = FavoritesService.instance;
      service.setFavoritesForTest(
        ids: {'term-1', 'training-1'},
        terms: [{'id': 'term-1', 'title': 'Extrusora'}],
        trainings: [{'id': 'training-1', 'title': 'Processo de Extrusão'}],
      );

      expect(service.isFavorite('term-1'), isTrue);
      expect(service.isFavorite('training-1'), isTrue);
      expect(service.isFavorite('resin-99'), isFalse);
    });

    testWidgets('ModuleEditorScreen initializes with empty attachments list for new modules',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModuleEditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure mock attachments v1 and d1 are not present
      expect(find.text('Processamento ...'), findsNothing);
      expect(find.text('Ficha Técnica ...'), findsNothing);
    });

    testWidgets('LessonDetailScreen hides Concluir Módulo when module is completed',
        (tester) async {
      const completedModule = TrainingModule(
        id: 'm1',
        order: 1,
        title: 'Módulo 1 Concluído',
        description: 'Descrição do módulo',
        isCompleted: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LessonDetailScreen(
              admin: false,
              module: completedModule,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Módulo Concluído'), findsOneWidget);
      expect(find.text('CONCLUIR MÓDULO'), findsNothing);
    });

    testWidgets('DoubtThreadScreen displays verificationData parameters and retains non-admin role',
        (tester) async {
      const doubtWithVerification = DoubtModel(
        id: 'doubt-spec-1',
        userId: 'op-1',
        userName: 'Operador Carlos',
        question: 'Variação na espessura do filme tubular',
        status: 'NAO_RESPONDIDO',
        createdAt: '30/09/2026',
        verificationData: {
          'Espessura': {
            'parameterName': 'Espessura',
            'target': '50 µm',
            'measuredValue': '65 µm',
            'deviation': '+15 µm',
          },
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DoubtThreadScreen(
              doubt: doubtWithVerification,
              admin: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify parameters are visible
      expect(find.text('Parâmetros de Verificação'), findsOneWidget);
      expect(find.textContaining('Espessura: Alvo=50 µm | Lido=65 µm | Desvio=+15 µm'), findsOneWidget);

      // Verify ticket status badge
      expect(find.text('ABERTA'), findsOneWidget);
    });

    testWidgets('ComparacaoVersoesConteudoScreen displays "Arquivo mantido (sem alteração)" when unchanged',
        (tester) async {
      final content = ContentModel(
        id: 'c1',
        title: 'Manutenção da Matriz',
        text: 'Texto atualizado',
        authorName: 'Maria',
        createdAt: '01/08/2026',
        updatedAt: '05/08/2026',
        documentName: 'manual_operacao.pdf',
        documentUrl: 'http://example.com/manual_operacao.pdf',
      );

      final previous = {
        'text': 'Texto antigo',
        'documentName': 'manual_operacao.pdf',
        'documentUrl': 'http://example.com/manual_operacao.pdf',
        'date': '01/08/2026',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComparacaoVersoesConteudoScreen(
              currentContent: content,
              previousSnapshot: previous,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Arquivo mantido (sem alteração)'), findsOneWidget);
    });
  });
}
