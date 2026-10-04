import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/resins/resins_screens.dart';
import 'package:pext/models/resin_model.dart';

void main() {
  testWidgets('renders ListaResinasScreen with Ex: Coextrusão placeholder and no heart button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ListaResinasScreen(admin: true),
      ),
    );

    expect(find.text('Resinas'), findsOneWidget);
    expect(find.text('Ex: Coextrusão'), findsOneWidget);
    // Favorite icon button must NOT exist in the cards list
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });

  testWidgets('renders FormularioResinaScreen with all tabs, standardized fields, and CADASTRAR button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FormularioResinaScreen(admin: true),
      ),
    );

    // Initial Overview tab
    expect(find.text('Visão Geral'), findsOneWidget);
    expect(find.text('Características'), findsOneWidget);
    expect(find.text('Propriedades'), findsOneWidget);
    expect(find.text('Mais'), findsOneWidget);
    expect(find.text('Nome do Material:'), findsOneWidget);
    expect(find.text('Nome técnico (opcional):'), findsOneWidget);
    expect(find.text('Sigla:'), findsOneWidget);
    expect(find.text('Descrição curta (multiline):'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Subcategoria (opcional):'), findsOneWidget);
    expect(find.text('Gerenciar Etapas'), findsOneWidget);
    expect(find.text('Gerenciar Aplicações'), findsOneWidget);
    expect(find.text('CADASTRAR'), findsOneWidget);

    // Switch to Características tab
    await tester.tap(find.text('Características'));
    await tester.pumpAndSettle();
    expect(find.text('Especificações Técnicas:'), findsOneWidget);
    expect(find.text('Densidade:'), findsOneWidget);
    expect(find.text('Índice de Fluídez (MFI):'), findsOneWidget);
    expect(find.text('Temperatura de Fusão:'), findsOneWidget);
    expect(find.text('Temperatura de deflexão térmica:'), findsOneWidget);
    expect(find.text('Resistência à Tração:'), findsOneWidget);
    expect(find.text('Alongamento na ruptura:'), findsOneWidget);
    expect(find.text('Módulo de Elasticidade:'), findsOneWidget);
    expect(find.text('Impacto Izod (23°C):'), findsOneWidget);
    expect(find.text('Dureza Rockwell:'), findsOneWidget);
    expect(find.text('Principais Características:'), findsOneWidget);
    expect(find.text('CADASTRAR'), findsOneWidget);

    // Switch to Propriedades tab
    await tester.tap(find.text('Propriedades'));
    await tester.pumpAndSettle();
    expect(find.text('Propriedades:'), findsOneWidget);
    expect(find.text('Rigidez'), findsOneWidget);
    expect(find.text('Resistência Química'), findsOneWidget);
    expect(find.text('Observações:'), findsOneWidget);
    expect(find.text('CADASTRAR'), findsOneWidget);

    // Switch to Mais tab
    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    expect(find.text('Documentos:'), findsOneWidget);
    expect(find.text('ANEXAR DOCUMENTO (PDF)'), findsOneWidget);
    expect(find.text('Vídeos:'), findsOneWidget);
    expect(find.text('ADICIONAR VÍDEO'), findsOneWidget);
    expect(find.text('Perguntas frequentes'), findsNothing); // FAQ completely removed!
    expect(find.text('CADASTRAR'), findsOneWidget);
  });

  testWidgets('renders DetalhesResinaScreen with quick metrics, Como Funciona, and admin action buttons',
      (WidgetTester tester) async {
    const mockResin = ResinModel(
      id: 'mock-1',
      name: 'Polietileno de Baixa Densidade',
      acronym: 'PEBD',
      categoryName: 'Termoplásticos',
      description: 'Descrição detalhada de como funciona.',
      observations: 'Observação personalizada do operador.',
      productionProcess: [
        ProductionStep(id: 's1', order: 1, title: 'Polimerização'),
        ProductionStep(id: 's2', order: 2, title: 'Granulação'),
      ],
      technicalData: [
        TechnicalDatum(id: 't1', key: 'Densidade:', value: '0.92 g/cm³'),
        TechnicalDatum(id: 't2', key: 'Temperatura de Fusão:', value: '115 °C'),
        TechnicalDatum(id: 't3', key: 'Índice de Fluídez (MFI):', value: '2.0 g/10 min'),
      ],
      properties: [
        ResinProperty(id: 'p1', name: 'Rigidez', level: 'Baixa'),
        ResinProperty(id: 'p2', name: 'Resistência Química', level: 'Alta'),
      ],
      applications: ['Embalagens', 'Tampas e Fechamentos'],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: DetalhesResinaScreen(
          resinId: 'mock-1',
          admin: true,
          initialResin: mockResin,
        ),
      ),
    );

    // Screen loads with full initialResin data
    await tester.pumpAndSettle();

    expect(find.text('Como Funciona?'), findsOneWidget);
    expect(find.text('Editar Conteúdo'), findsOneWidget);
    expect(find.text('Excluir Conteúdo'), findsOneWidget);
    // Favorite icon MUST NOT be present on admin screen
    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });
}
