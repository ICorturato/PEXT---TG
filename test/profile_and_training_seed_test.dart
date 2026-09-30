import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/services/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile and User Management Tests', () {
    testWidgets('UserProfileScreen renders user details and admin registration card for admins',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserProfileScreen(admin: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header title and tab
      expect(find.text('Perfil'), findsWidgets);
      expect(find.text('Dados'), findsOneWidget);
      expect(find.text('Segurança'), findsOneWidget);

      // Verify that admin sees "Cadastrar Novo Usuário" action card
      expect(find.text('Cadastrar Novo Usuário'), findsOneWidget);
      expect(find.text('Adicionar novo operador ou colaborador ao sistema'), findsOneWidget);
    });

    testWidgets('UserProfileScreen hides admin registration card for standard users',
        (tester) async {
      ApiClient.instance.session.clear();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserProfileScreen(admin: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar Novo Usuário'), findsNothing);
    });
  });

  group('Training 29-Question Seed & Validation Tests', () {
    testWidgets('TrainingEditorScreen initializes with 29 questions seed and disables CADASTRAR until 30',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrainingEditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check button text is CADASTRAR
      final cadastrarFinder = find.widgetWithText(FilledButton, 'CADASTRAR');
      expect(cadastrarFinder, findsOneWidget);

      // Verify CADASTRAR is disabled because question count is 29 (< 30)
      final button = tester.widget<FilledButton>(cadastrarFinder);
      expect(button.onPressed, isNull);

      // Switch to Avaliação tab to verify 29 questions exist
      await tester.tap(find.text('Avaliação'));
      await tester.pumpAndSettle();

      expect(find.text('29 questões cadastradas.'), findsOneWidget);
      expect(find.text('Mínimo: 30 | Máximo: 50 questões'), findsOneWidget);
    });
  });
}
