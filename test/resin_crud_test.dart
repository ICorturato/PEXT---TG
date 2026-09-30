import 'package:flutter_test/flutter_test.dart';
import 'package:pext/models/resin_model.dart';

void main() {
  group('ResinModel CRUD & Serialization Tests', () {
    test('serializes and deserializes ResinModel with custom acronym and fields', () {
      const initial = ResinModel(
        id: 'resin-123',
        name: 'Polietileno de Baixa Densidade',
        acronym: 'PEBD',
        categoryId: 'cat-polymers',
        categoryName: 'Polímeros',
        imageUrl: '/uploads/pebd.jpg',
        description: 'Resina flexível usada para sacolas e filmes.',
        productionProcess: [
          ProductionStep(id: 's1', order: 1, title: 'Matéria-Prima (Etileno)'),
          ProductionStep(id: 's2', order: 2, title: 'Polimerização tubular'),
          ProductionStep(id: 's3', order: 3, title: 'Granulação'),
        ],
        applications: ['Filmes agrícolas', 'Sacos plásticos'],
        technicalData: [
          TechnicalDatum(id: 't1', key: 'Densidade', value: '0.92 g/cm³'),
          TechnicalDatum(id: 't2', key: 'MFI', value: '2.0 g/10 min'),
        ],
        properties: [
          ResinProperty(id: 'p1', name: 'Flexibilidade', level: 'Alta'),
          ResinProperty(id: 'p2', name: 'Rigidez', level: 'Baixa'),
        ],
        observations: 'Manter afastado de solventes clorados.',
        videos: [
          ResinVideo(
            id: 'v1',
            type: 'YOUTUBE',
            urlOrPath: 'https://youtube.com/watch?v=pebd123',
            title: 'Linha PEBD',
          ),
          ResinVideo(
            id: 'v2',
            type: 'GALLERY',
            urlOrPath: '/uploads/vid.mp4',
            title: 'Extrusão na Fábrica',
          ),
        ],
        documents: [
          ResinDocument(
            id: 'd1',
            name: 'Ficha_Tecnica_PEBD.pdf',
            urlOrPath: '/uploads/ficha.pdf',
            fileSize: '1.5 MB',
            extension: 'PDF',
          ),
        ],
        isFavorite: true,
      );

      final json = initial.toJson();

      // Verify JSON output preserves both primary and backward-compatible fields
      expect(json['id'], 'resin-123');
      expect(json['name'], 'Polietileno de Baixa Densidade');
      expect(json['fullName'], 'Polietileno de Baixa Densidade');
      expect(json['acronym'], 'PEBD');
      expect(json['code'], 'PEBD');
      expect(json['categoryId'], 'cat-polymers');
      expect(json['categoryName'], 'Polímeros');
      expect(json['imageUrl'], '/uploads/pebd.jpg');
      expect(json['description'], 'Resina flexível usada para sacolas e filmes.');
      expect(json['observations'], 'Manter afastado de solventes clorados.');

      final restored = ResinModel.fromJson(json, isFavorite: true);

      expect(restored.id, 'resin-123');
      expect(restored.name, 'Polietileno de Baixa Densidade');
      expect(restored.acronym, 'PEBD');
      expect(restored.categoryId, 'cat-polymers');
      expect(restored.categoryName, 'Polímeros');
      expect(restored.imageUrl, '/uploads/pebd.jpg');
      expect(restored.description, 'Resina flexível usada para sacolas e filmes.');
      expect(restored.observations, 'Manter afastado de solventes clorados.');
      expect(restored.isFavorite, isTrue);

      // Verify flowchart steps
      expect(restored.productionProcess.length, 3);
      expect(restored.productionProcess[0].order, 1);
      expect(restored.productionProcess[0].title, 'Matéria-Prima (Etileno)');
      expect(restored.productionProcess[1].order, 2);
      expect(restored.productionProcess[2].order, 3);

      // Verify applications tags
      expect(restored.applications, ['Filmes agrícolas', 'Sacos plásticos']);

      // Verify technical data
      expect(restored.technicalData.length, 2);
      expect(restored.technicalData[0].key, 'Densidade');
      expect(restored.technicalData[0].value, '0.92 g/cm³');

      // Verify properties
      expect(restored.properties.length, 2);
      expect(restored.properties[0].name, 'Flexibilidade');
      expect(restored.properties[0].level, 'Alta');

      // Verify videos and documents
      expect(restored.videos.length, 2);
      expect(restored.videos[0].type, 'YOUTUBE');
      expect(restored.videos[1].type, 'GALLERY');
      expect(restored.documents.length, 1);
      expect(restored.documents[0].extension, 'PDF');
    });

    test('supports dynamic addition, removal, and reordering of flowchart steps', () {
      final steps = <ProductionStep>[
        const ProductionStep(id: 's1', order: 1, title: 'Step 1'),
        const ProductionStep(id: 's2', order: 2, title: 'Step 2'),
        const ProductionStep(id: 's3', order: 3, title: 'Step 3'),
      ];

      // Add a step
      steps.add(const ProductionStep(id: 's4', order: 4, title: 'Step 4'));
      expect(steps.length, 4);

      // Remove a step
      steps.removeWhere((s) => s.id == 's2');
      expect(steps.length, 3);

      // Reorder steps
      final reordered = List<ProductionStep>.generate(steps.length, (i) {
        return steps[i].copyWith(order: i + 1);
      });
      expect(reordered[0].title, 'Step 1');
      expect(reordered[0].order, 1);
      expect(reordered[1].title, 'Step 3');
      expect(reordered[1].order, 2);
      expect(reordered[2].title, 'Step 4');
      expect(reordered[2].order, 3);
    });

    test('supports dynamic addition and removal of technical data entries', () {
      final tech = <TechnicalDatum>[
        const TechnicalDatum(id: 't1', key: 'Densidade', value: '0.91'),
        const TechnicalDatum(id: 't2', key: 'MFI', value: '12'),
      ];

      // Remove one item
      tech.removeWhere((t) => t.id == 't1');
      expect(tech.length, 1);
      expect(tech.first.key, 'MFI');

      // Add new item
      tech.add(const TechnicalDatum(id: 't3', key: 'HDT', value: '95°C'));
      expect(tech.length, 2);
      expect(tech.last.key, 'HDT');
      expect(tech.last.value, '95°C');
    });

    test('supports custom flowchart icons, images, and custom application metadata serialization', () {
      ApplicationCatalogService.register(
        'Peças Automotivas',
        iconKey: 'car',
        imageUrl: '/uploads/car_app.png',
      );

      const model = ResinModel(
        id: 'resin-custom',
        name: 'PP Homopolímero',
        acronym: 'PPH',
        productionProcess: [
          ProductionStep(
            id: 'p1',
            order: 1,
            title: 'Extrusão Inicial',
            iconName: 'reactor',
            imageUrl: '/uploads/custom_step.jpg',
          ),
        ],
        applications: ['Peças Automotivas'],
      );

      final json = model.toJson();
      final appsJson = json['applications'] as List;
      expect(appsJson.first, isA<Map<String, dynamic>>());
      expect((appsJson.first as Map)['title'], 'Peças Automotivas');
      expect((appsJson.first as Map)['iconKey'], 'car');
      expect((appsJson.first as Map)['imageUrl'], '/uploads/car_app.png');

      // Clear local registry and deserialize from JSON
      ApplicationCatalogService.clear();
      expect(ApplicationCatalogService.get('Peças Automotivas'), isNull);

      final restored = ResinModel.fromJson(json);
      expect(restored.applications, ['Peças Automotivas']);
      expect(restored.productionProcess.first.iconName, 'reactor');
      expect(restored.productionProcess.first.imageUrl, '/uploads/custom_step.jpg');

      // Verify ApplicationCatalogService was automatically restored during fromJson
      final restoredMeta = ApplicationCatalogService.get('Peças Automotivas');
      expect(restoredMeta, isNotNull);
      expect(restoredMeta!.iconKey, 'car');
      expect(restoredMeta.imageUrl, '/uploads/car_app.png');
    });
  });
}
