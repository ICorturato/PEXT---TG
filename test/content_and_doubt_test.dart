import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/models/content_model.dart';
import 'package:pext/models/doubt_model.dart';
import 'package:pext/models/packaging_specification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentModel & DoubtModel Tests', () {
    test('ContentModel serialization, deserialization, and audit history', () {
      final audit = ContentAuditEntry(
        id: 'aud-1',
        authorName: 'Maria',
        authorRole: 'ADMIN',
        action: 'UPDATE',
        date: '02/08/2026 - 09:43',
        title: 'Maria editou o conteúdo',
        description: 'Alterações:\n- Inclusão de Documento',
        previousContent: {
          'title': 'Versão Inicial',
          'text': 'Texto antigo',
          'date': '01/08/2026 - 09:30',
        },
      );

      final content = ContentModel(
        id: 'cont-1',
        title: 'Material irregular na matriz',
        text: 'Inspeção necessária na matriz de extrusão.',
        categoryName: 'Extrusão',
        documentName: 'Ficha Técnica.pdf',
        documentSize: 'PDF - 1,2 MB',
        authorName: 'André',
        createdAt: '01/08/2026',
        updatedAt: '03/07/2026',
        history: [audit],
      );

      final jsonMap = content.toJson();
      expect(jsonMap['title'], equals('Material irregular na matriz'));
      expect(jsonMap['categoryName'], equals('Extrusão'));
      expect(jsonMap['documentName'], equals('Ficha Técnica.pdf'));

      final restored = ContentModel.fromJson(jsonMap);
      expect(restored.id, equals('cont-1'));
      expect(restored.history.length, equals(1));
      expect(restored.history.first.previousContent?['title'], equals('Versão Inicial'));
    });

    test('DoubtModel and DoubtMessage escalation and admin reply', () {
      final doubt = DoubtModel(
        id: 'd-1',
        userId: 'u1',
        userName: 'Igor Teixeira Corturato',
        question: 'O que pode fazer o material sair da matriz de forma irregular',
        status: 'NAO_RESPONDIDO',
        createdAt: '08/08/2026',
        messages: const [
          DoubtMessage(
            id: 'm1',
            senderId: 'u1',
            senderName: 'Igor Teixeira Corturato',
            senderRole: 'USER',
            text: 'O que pode fazer o material sair da matriz de forma irregular',
            createdAt: '08/08/2026 - 10:00',
          ),
        ],
      );

      expect(doubt.isAnswered, isFalse);

      final adminReply = const DoubtMessage(
        id: 'm2',
        senderId: 'admin-1',
        senderName: 'Administrador PEXT',
        senderRole: 'ADMIN',
        text: 'Verifique as temperaturas e o perfil térmico.',
        createdAt: '08/08/2026 - 10:15',
      );

      expect(adminReply.isAdmin, isTrue);

      final updated = doubt.copyWith(
        status: 'RESPONDIDO',
        messages: [...doubt.messages, adminReply],
      );

      expect(updated.isAnswered, isTrue);
      expect(updated.messages.length, equals(2));
      expect(updated.messages.last.isAdmin, isTrue);
    });
  });

  group('Assistant and Content Widget Tests', () {
    testWidgets('renders ChatAssistantScreen with 3 tabs in admin mode',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatAssistantScreen(admin: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assistente IA'), findsOneWidget);
      expect(find.text('Chat'), findsNWidgets(2));
      expect(find.text('Dúvidas'), findsOneWidget);
      expect(find.text('Conteúdo'), findsOneWidget);
    });

    testWidgets('renders DetalhesConteudoScreen with action buttons and history',
        (tester) async {
      final content = ContentModel(
        id: 'test-1',
        title: 'Material irregular na matriz',
        text: 'Texto de teste',
        authorName: 'André',
        createdAt: '01/08/2026',
        updatedAt: '03/07/2026',
        history: const [
          ContentAuditEntry(
            id: 'h1',
            authorName: 'André',
            action: 'CREATE',
            date: '01/08/2026 - 09:33',
            title: 'André criou este conteúdo.',
            description: 'Conteúdo inicial adicionado.',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DetalhesConteudoScreen(content: content),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar Conteúdo'), findsOneWidget);
      expect(find.text('Excluir Conteúdo'), findsOneWidget);
      expect(find.text('Histórico de alteração'), findsOneWidget);
      expect(find.text('André criou este conteúdo.'), findsOneWidget);
    });

    testWidgets('renders CadastroConteudoScreen with category and document actions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CadastroConteudoScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('NOVO CONTEÚDO'), findsOneWidget);
      expect(find.text('Digite o tema'), findsOneWidget);
      expect(find.text('Conteúdo'), findsOneWidget);
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Anexar Documentação'), findsOneWidget);
      expect(find.text('ADICIONAR DOCUMENTO'), findsOneWidget);
      expect(find.text('CADASTRAR'), findsOneWidget);
    });

    testWidgets(
        'renders PackagingDetailScreen with action buttons immediately under the image container',
        (tester) async {
      PackagingCatalog.replace([
        PackagingSpecification(
          name: 'RAP10',
          imageUrl: '/uploads/bbbf56b8-7cab-4b76-8ea9-4ed9e379ebee.jpg',
          parameters: [
            PackagingParameter(
              name: 'Temperatura do cilindro',
              unit: '°C',
              min: 160,
              max: 180,
            ),
          ],
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: PackagingDetailScreen(
            admin: true,
            packagingName: 'RAP10',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RAP10'), findsOneWidget);
      expect(find.text('Editar Embalagem'), findsOneWidget);
      expect(find.text('Excluir Embalagem'), findsOneWidget);

      // Verify Editar Embalagem is positioned before Composição and Parâmetros de Produção
      final editBtnPos = tester.getTopLeft(find.text('Editar Embalagem')).dy;
      final composicaoPos = tester.getTopLeft(find.text('Composição')).dy;
      expect(editBtnPos, lessThan(composicaoPos));
    });
  });
}
