import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/models/training_model.dart';
import 'package:pext/services/training_service.dart';

void main() {
  setUp(() {
    TrainingService.instance.setTrainingsForTest([
      TrainingModel(
        id: 'mock_1',
        title: 'Extrusão Básica',
        categoryName: 'Extrusão',
        categoryId: 'cat_ext',
        description: 'Treinamento sobre filmes e sopragem.',
        workload: '20h',
        passingGrade: 70,
        questionCount: 30,
        thumbnailUrl: '',
        modules: [
          TrainingModule(
            id: 'mod_1',
            order: 1,
            title: 'Módulo 1: Setup da Extrusora',
            description: 'Instalação de matriz e calibração de rosca.',
            videos: [
              TrainingVideo(id: 'v_1', title: 'Video Aula 1', duration: '12:00', urlOrPath: ''),
            ],
            documents: [
              TrainingDocument(id: 'd_1', title: 'Apostila 1.pdf', fileSize: '2.1 MB', urlOrPath: ''),
            ],
          ),
        ],
        questions: [],
      ),
    ]);
  });

  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('renders TrainingDetailScreen with equalized KPI cards and action buttons', (tester) async {
    final training = TrainingService.instance.trainings.first;
    await tester.pumpWidget(buildTestable(TrainingDetailScreen(training: training, admin: false)));
    await tester.pumpAndSettle();

    expect(find.text('Extrusão Básica'), findsOneWidget);
    expect(find.text('Módulos'), findsOneWidget);
    expect(find.text('Concluídos'), findsOneWidget);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('Módulo 1: Setup da Extrusora'), findsOneWidget);
  });

  testWidgets('renders LessonDetailScreen with outlined action buttons and tabs', (tester) async {
    final training = TrainingService.instance.trainings.first;
    final module = training.modules.first;

    await tester.pumpWidget(buildTestable(LessonDetailScreen(
      training: training,
      module: module,
      admin: true,
    )));
    await tester.pumpAndSettle();

    expect(find.text('Módulo 1: Setup da Extrusora'), findsWidgets);
    expect(find.text('Conteúdo'), findsOneWidget);
    expect(find.text('Documentação'), findsOneWidget);
    expect(find.text('Excluir Conteúdo'), findsOneWidget);
    expect(find.text('Editar Conteúdo'), findsOneWidget);
    expect(find.text('Sobre esta aula'), findsOneWidget);
  });

  testWidgets('renders TrainingEditorScreen (NovoTreinamentoScreen) with 3 tabs and form fields', (tester) async {
    await tester.pumpWidget(buildTestable(const TrainingEditorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Visão Geral'), findsOneWidget);
    expect(find.text('Módulos'), findsOneWidget);
    expect(find.text('Avaliação'), findsOneWidget);

    // Click on Módulos tab
    await tester.tap(find.text('Módulos'));
    await tester.pumpAndSettle();
    expect(find.text('ADICIONAR MÓDULO'), findsOneWidget);

    // Click on Avaliação tab
    await tester.tap(find.text('Avaliação'));
    await tester.pumpAndSettle();
    expect(find.text('questões cadastradas'), findsOneWidget);
    expect(find.text('Nota mínima para aprovação'), findsOneWidget);
    expect(find.text('Mínimo: 30 | Máximo: 50 questões'), findsOneWidget);
    expect(find.text('Gerenciar Questões'), findsOneWidget);
  });

  testWidgets('renders ModuleEditorScreen (NovoModuloScreen) with attachment actions', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestable(const ModuleEditorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Novo Módulo'), findsOneWidget);
    expect(find.text('Título do módulo'), findsOneWidget);
    expect(find.text('Descrição curta'), findsOneWidget);
    expect(find.text('Vídeos do módulo'), findsOneWidget);
    expect(find.text('Documentos'), findsOneWidget);
    expect(find.text('ADICIONAR'), findsWidgets);
    expect(find.text('CADASTRAR'), findsOneWidget);
  });

  testWidgets('renders QuestionTypeSelectorScreen with 3 question types', (tester) async {
    await tester.pumpWidget(buildTestable(const QuestionTypeSelectorScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Questões'), findsOneWidget);
    expect(find.text('Resposta Única'), findsOneWidget);
    expect(find.text('Verdadeiro ou Falso'), findsOneWidget);
    expect(find.text('Múltipla Escolha'), findsOneWidget);
    expect(find.text('ANTERIOR'), findsOneWidget);
    expect(find.text('PRÓXIMO'), findsOneWidget);
  });
}
