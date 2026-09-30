import 'package:flutter_test/flutter_test.dart';
import 'package:pext/models/training_model.dart';

void main() {
  group('TrainingModel CRUD & Serialization Tests', () {
    test('serializes and deserializes TrainingModel with modules and assessment', () {
      final initial = TrainingModel(
        id: 'train_1',
        title: 'Extrusão de Filmes Tubulares',
        categoryName: 'Extrusão',
        categoryId: 'cat_extrusao',
        description: 'Capacitação completa em processos de extrusão tubular.',
        workload: '40h',
        passingGrade: 75,
        questionCount: 35,
        thumbnailUrl: '/uploads/training/cover_1.jpg',
        modules: [
          TrainingModule(
            id: 'mod_1',
            order: 1,
            title: 'Introdução à Extrusão',
            description: 'Conceitos fundamentais e termodinâmica do polímero.',
            videos: [
              TrainingVideo(
                id: 'vid_1',
                title: 'Aula 1 - O Cabeçote de Matriz',
                duration: '14:20',
                urlOrPath: '/uploads/videos/aula1.mp4',
              ),
            ],
            documents: [
              TrainingDocument(
                id: 'doc_1',
                title: 'Manual Técnico de Operação',
                fileSize: '3.4 MB',
                urlOrPath: '/uploads/docs/manual.pdf',
              ),
            ],
          ),
        ],
        questions: [
          TrainingQuestion(
            id: 'q_1',
            order: 1,
            prompt: 'Qual a temperatura ideal da zona 3 no PEBD?',
            type: 'single',
            alternatives: [
              TrainingAlternative(id: 'alt_1', letter: 'A', text: '160°C - 180°C', isCorrect: true),
              TrainingAlternative(id: 'alt_2', letter: 'B', text: '240°C - 260°C', isCorrect: false),
            ],
          ),
        ],
      );

      final json = initial.toJson();
      expect(json['id'], 'train_1');
      expect(json['title'], 'Extrusão de Filmes Tubulares');
      expect(json['questionCount'], 35);
      expect(json['passingGrade'], 75);
      expect((json['modules'] as List).length, 1);
      expect((json['questions'] as List).length, 1);

      final deserialized = TrainingModel.fromJson(json);
      expect(deserialized.id, initial.id);
      expect(deserialized.title, initial.title);
      expect(deserialized.categoryName, initial.categoryName);
      expect(deserialized.categoryId, initial.categoryId);
      expect(deserialized.description, initial.description);
      expect(deserialized.workload, initial.workload);
      expect(deserialized.questionCount, 35);
      expect(deserialized.passingGrade, 75);
      expect(deserialized.thumbnailUrl, initial.thumbnailUrl);

      expect(deserialized.modules.length, 1);
      final mod = deserialized.modules.first;
      expect(mod.id, 'mod_1');
      expect(mod.title, 'Introdução à Extrusão');
      expect(mod.videos.length, 1);
      expect(mod.videos.first.title, 'Aula 1 - O Cabeçote de Matriz');
      expect(mod.documents.length, 1);
      expect(mod.documents.first.title, 'Manual Técnico de Operação');

      expect(deserialized.questions.length, 1);
      final q = deserialized.questions.first;
      expect(q.id, 'q_1');
      expect(q.prompt, 'Qual a temperatura ideal da zona 3 no PEBD?');
      expect(q.alternatives.length, 2);
      expect(q.alternatives.first.isCorrect, isTrue);
    });

    test('validates question count constraint between 30 and 50', () {
      bool isValidQuestionCount(int? count) {
        if (count == null) return false;
        return count >= 30 && count <= 50;
      }

      expect(isValidQuestionCount(null), isFalse);
      expect(isValidQuestionCount(0), isFalse);
      expect(isValidQuestionCount(29), isFalse);
      expect(isValidQuestionCount(30), isTrue);
      expect(isValidQuestionCount(35), isTrue);
      expect(isValidQuestionCount(50), isTrue);
      expect(isValidQuestionCount(51), isFalse);
      expect(isValidQuestionCount(100), isFalse);
    });

    test('supports True/False and Multiple Choice question formats', () {
      final tfQuestion = TrainingQuestion(
        id: 'q_tf',
        order: 1,
        prompt: 'O índice de fluidez do PEBD é inversamente proporcional à viscosidade.',
        type: 'true_false',
        alternatives: [
          TrainingAlternative(id: 'vf_0', letter: 'V', text: 'Verdadeiro', isCorrect: true),
          TrainingAlternative(id: 'vf_1', letter: 'F', text: 'Falso', isCorrect: false),
        ],
      );

      final mcQuestion = TrainingQuestion(
        id: 'q_mc',
        order: 2,
        prompt: 'Selecione os aditivos comuns em poliolefinas:',
        type: 'multiple',
        alternatives: [
          TrainingAlternative(id: 'm_0', letter: 'A', text: 'Anti-bloqueio', isCorrect: true),
          TrainingAlternative(id: 'm_1', letter: 'B', text: 'Deslizante', isCorrect: true),
          TrainingAlternative(id: 'm_2', letter: 'C', text: 'Plastificante ftalato', isCorrect: false),
        ],
      );

      expect(tfQuestion.type, 'true_false');
      expect(tfQuestion.alternatives.where((a) => a.isCorrect).length, 1);
      expect(mcQuestion.type, 'multiple');
      expect(mcQuestion.alternatives.where((a) => a.isCorrect).length, 2);
    });
  });
}
