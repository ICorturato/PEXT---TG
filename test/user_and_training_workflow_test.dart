import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/admin/admin_user_screens.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/models/training_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Training Journey & Assessment Tests', () {
    test('TrainingModel correctly reports completion and enrollment status', () {
      final uncompletedTraining = TrainingModel(
        id: 't1',
        title: 'Curso Básico',
        description: 'Descrição',
        isDefaultForAllUsers: true,
        modules: const [
          TrainingModule(id: 'm1', order: 1, title: 'Mod 1', description: '', isCompleted: true),
          TrainingModule(id: 'm2', order: 2, title: 'Mod 2', description: '', isCompleted: false),
        ],
      );

      expect(uncompletedTraining.areAllModulesCompleted, isFalse);
      expect(uncompletedTraining.completedModuleCount, 1);
      expect(uncompletedTraining.isDefaultForAllUsers, isTrue);

      final completedTraining = TrainingModel(
        id: 't2',
        title: 'Curso Avançado',
        description: 'Descrição',
        isDefaultForAllUsers: false,
        isEnrolled: true,
        modules: const [
          TrainingModule(id: 'm1', order: 1, title: 'Mod 1', description: '', isCompleted: true),
          TrainingModule(id: 'm2', order: 2, title: 'Mod 2', description: '', isCompleted: true),
        ],
      );

      expect(completedTraining.areAllModulesCompleted, isTrue);
      expect(completedTraining.completedModuleCount, 2);
      expect(completedTraining.isDefaultForAllUsers, isFalse);
      expect(completedTraining.isEnrolled, isTrue);
    });

    testWidgets('Course progress card displays "VER TESTE" button when all modules are completed',
        (tester) async {
      bool assessmentTapped = false;
      final completedTraining = TrainingModel(
        id: 't_comp',
        title: 'Curso Completo',
        description: 'Todos os módulos feitos',
        modules: const [
          TrainingModule(id: 'm1', order: 1, title: 'Mod 1', description: '', isCompleted: true),
          TrainingModule(id: 'm2', order: 2, title: 'Mod 2', description: '', isCompleted: true),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingDetailScreen(
              admin: false,
              completed: true,
              training: completedTraining,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expect the assessment button to be rendered
      expect(find.text('VER TESTE / REALIZAR AVALIAÇÃO'), findsOneWidget);
      expect(find.text('Parabéns! Todos os módulos foram concluídos'), findsOneWidget);
    });

    testWidgets('Locked module displays "Bloqueado" tag and lock icon',
        (tester) async {
      final training = TrainingModel(
        id: 't_locked',
        title: 'Curso Bloqueado',
        description: 'Primeiro feito, segundo bloqueado',
        modules: const [
          TrainingModule(id: 'm1', order: 1, title: 'Mod 1', description: '', isCompleted: false),
          TrainingModule(id: 'm2', order: 2, title: 'Mod 2', description: '', isCompleted: false),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingDetailScreen(
              admin: false,
              completed: false,
              training: training,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Module 2 should be locked because Module 1 is not completed
      expect(find.text('Bloqueado'), findsOneWidget);
    });

    testWidgets('ExamScreen renders questions and options', (tester) async {
      final examTraining = TrainingModel(
        id: 't_exam',
        title: 'Avaliação Operacional',
        description: 'Teste prático',
        questions: const [
          TrainingQuestion(
            id: 'q1',
            order: 1,
            prompt: 'Qual a temperatura ideal de fusão?',
            alternatives: [
              TrainingAlternative(id: 'a1', letter: 'A', text: '180°C a 200°C', isCorrect: true),
              TrainingAlternative(id: 'a2', letter: 'B', text: '50°C a 60°C', isCorrect: false),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExamScreen(training: examTraining),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Qual a temperatura ideal de fusão?'), findsOneWidget);
      expect(find.text('180°C a 200°C'), findsOneWidget);
      expect(find.text('50°C a 60°C'), findsOneWidget);
      expect(find.text('FINALIZAR TESTE'), findsOneWidget);
    });
  });

  group('Admin User Management Screen Tests', () {
    testWidgets('AdminUserManagementScreen renders catalog header and new user button',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdminUserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gestão de Usuários'), findsOneWidget);
      expect(find.text('NOVO USUÁRIO'), findsOneWidget);
      expect(find.textContaining('Usuários Cadastrados'), findsOneWidget);
    });

    testWidgets('AdminUserDetailScreen renders personal information card and enrolled trainings',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(
            body: AdminUserDetailScreen(
              userId: 'user-1',
              initialData: {
                'name': 'Carlos Silva',
                'email': 'carlos@pext.ind.br',
                'cargo': 'Operador de Máquina',
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Carlos Silva'), findsWidgets);
      expect(find.text('carlos@pext.ind.br'), findsOneWidget);
      expect(find.textContaining('Treinamentos Matriculados'), findsOneWidget);
    });
  });
}
