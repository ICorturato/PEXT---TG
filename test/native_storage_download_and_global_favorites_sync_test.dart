import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/core/core_screens.dart';
import 'package:pext/main.dart';
import 'package:pext/models/training_model.dart';
import 'package:pext/services/favorites_service.dart';
import 'package:pext/services/file_download_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FavoritesNotifier.instance.setFavoritesForTest(
      ids: {},
      mockNetwork: true,
    );
  });

  group('1. FileDownloadService: Native Storage Downloads & Open File', () {
    test('downloadToPublicFolder creates file and returns valid file path', () async {
      final path = await FileDownloadService.downloadToPublicFolder(
        url: '',
        fileName: 'Guia_Pratico_Extrusao.pdf',
      );

      expect(path, isNotNull);
      expect(path!.isNotEmpty, isTrue);
      expect(File(path).existsSync(), isTrue);

      // Clean up test file
      try {
        File(path).deleteSync();
      } catch (_) {}
    });

    test('openDownloadedFile runs without uncaught exceptions', () async {
      final path = await FileDownloadService.downloadToPublicFolder(
        url: '',
        fileName: 'Ficha_Seguranca.pdf',
      );
      expect(path, isNotNull);

      // Should complete gracefully in test environment
      await expectLater(
        FileDownloadService.openDownloadedFile(path!),
        completes,
      );

      try {
        File(path).deleteSync();
      } catch (_) {}
    });

    testWidgets('downloadFile displays SnackBar with ABRIR action', (tester) async {
      BuildContext? capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Download Test Screen');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await FileDownloadService.instance.downloadFile(
        capturedContext!,
        url: '',
        filename: 'Especificacao_Tecnica.pdf',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Salvo na pasta Downloads: Especificacao_Tecnica.pdf'), findsOneWidget);
      expect(find.text('ABRIR'), findsOneWidget);
    });
  });

  group('2. FavoritesNotifier: Global Reactive Source of Truth & Synchronization', () {
    test('FavoritesNotifier maintains global reactive set and provides isFavorited / toggleFavorite', () async {
      final notifier = FavoritesNotifier.instance;
      expect(notifier.isFavorited('course-101'), isFalse);

      await notifier.toggleFavorite(
        entityType: 'TRAINING',
        entityId: 'course-101',
      );
      expect(notifier.isFavorited('course-101'), isTrue);
      expect(notifier.state.contains('course-101'), isTrue);

      await notifier.toggleFavoriteEntity('course-101', 'TRAINING');
      expect(notifier.isFavorited('course-101'), isFalse);
    });

    testWidgets('TrainingDetailScreen renders filled red heart when favorited in global store', (tester) async {
      FavoritesNotifier.instance.setFavoritesForTest(
        ids: {'training-alpha'},
        mockNetwork: true,
      );

      final training = TrainingModel(
        id: 'training-alpha',
        title: 'Manutenção de Roscas e Cilindros',
        description: 'Capacitação completa em manutenção preventiva',
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

      // Find filled red heart icon in app bar
      final filledHeart = find.byWidgetPredicate((widget) {
        return widget is Icon && widget.icon == Icons.favorite && widget.color == const Color(0xFFEF4444);
      });
      expect(filledHeart, findsOneWidget);

      // Tap to toggle favorite (unfavorite)
      await tester.tap(filledHeart);
      await tester.pumpAndSettle();

      // Verified global store updated immediately
      expect(FavoritesNotifier.instance.isFavorited('training-alpha'), isFalse);

      // Header icon updated to favorite_border
      final borderHeart = find.byWidgetPredicate((widget) {
        return widget is Icon && widget.icon == Icons.favorite_border;
      });
      expect(borderHeart, findsOneWidget);
    });

    testWidgets('HomeScreen training favorite icon and TrainingDetailScreen stay perfectly in sync', (tester) async {
      FavoritesNotifier.instance.setFavoritesForTest(
        ids: {},
        mockNetwork: true,
      );

      // Render home screen favorite icon
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTrainingFavoriteIcon(trainingId: 'training-beta'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      // Tap to favorite from home screen card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(FavoritesNotifier.instance.isFavorited('training-beta'), isTrue);
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Now open TrainingDetailScreen for the same training
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrainingDetailScreen(
              training: TrainingModel(
                id: 'training-beta',
                title: 'Controle de Espessura',
                description: 'Ajuste de matriz e anel de ar',
              ),
              admin: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Training detail must display filled red heart because global store holds the favorited ID
      final detailFilledHeart = find.byWidgetPredicate((widget) {
        return widget is Icon && widget.icon == Icons.favorite && widget.color == const Color(0xFFEF4444);
      });
      expect(detailFilledHeart, findsOneWidget);
    });
  });
}
