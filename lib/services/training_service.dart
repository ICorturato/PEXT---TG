import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_category.dart';
import '../models/training_model.dart';
import 'api_client.dart';

class TrainingService extends ChangeNotifier {
  static final TrainingService instance = TrainingService._internal();
  TrainingService._internal();

  final List<TrainingModel> _trainings = [];
  List<AppCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TrainingModel> get trainings => List.unmodifiable(_trainings);
  List<AppCategory> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setTrainingsForTest(List<TrainingModel> items) {
    _trainings.clear();
    _trainings.addAll(items);
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final list = await ApiClient.instance.categories(CategoryScope.training);
      _categories = list;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading training categories: $e');
    }
  }

  Future<List<TrainingModel>> fetchTrainings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await ApiClient.instance.content('trainings');
      _trainings.clear();
      for (final item in list) {
        _trainings.add(TrainingModel.fromJson(item.data));
      }
      await loadCategories();
      _isLoading = false;
      notifyListeners();
      return _trainings;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<TrainingModel?> getTrainingById(String id) async {
    try {
      final item = await ApiClient.instance.contentRecord('trainings', id);
      return TrainingModel.fromJson(item.data);
    } catch (e) {
      debugPrint('Error getting training $id: $e');
      return null;
    }
  }

  Future<TrainingModel> createTraining(
    TrainingModel training, {
    XFile? imageFile,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    String? uploadedUrl = training.thumbnailUrl;
    if (imageFile != null) {
      uploadedUrl = await ApiClient.instance.uploadImage(imageFile);
    } else if (imageBytes != null && imageBytes.isNotEmpty) {
      uploadedUrl = await ApiClient.instance.uploadMediaBytes(
        bytes: imageBytes,
        filename: imageFilename ?? 'training_cover.jpg',
        contentType: 'image/jpeg',
      );
    }

    final toCreate = training.copyWith(thumbnailUrl: uploadedUrl);
    final response = await ApiClient.instance.createContent('trainings', toCreate.toJson());
    final created = TrainingModel.fromJson(response.data);
    _trainings.insert(0, created);
    notifyListeners();
    return created;
  }

  Future<TrainingModel> updateTraining(
    String id,
    TrainingModel training, {
    XFile? imageFile,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    String? uploadedUrl = training.thumbnailUrl;
    if (imageFile != null) {
      uploadedUrl = await ApiClient.instance.uploadImage(imageFile);
    } else if (imageBytes != null && imageBytes.isNotEmpty) {
      uploadedUrl = await ApiClient.instance.uploadMediaBytes(
        bytes: imageBytes,
        filename: imageFilename ?? 'training_cover.jpg',
        contentType: 'image/jpeg',
      );
    }

    final toUpdate = training.copyWith(thumbnailUrl: uploadedUrl);
    final response = await ApiClient.instance.updateContent('trainings', id, toUpdate.toJson());
    final updated = TrainingModel.fromJson(response.data);

    final idx = _trainings.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _trainings[idx] = updated;
    }
    notifyListeners();
    return updated;
  }

  List<TrainingModel> get inProgressTrainings => _trainings
      .where((t) =>
          (t.isEnrolled || t.isDefaultForAllUsers || t.isObrigatorio) &&
          !t.areAllModulesCompleted &&
          !t.isApproved &&
          t.enrollmentStatus != 'DROPPED')
      .toList();

  List<TrainingModel> get readyForAssessmentTrainings => _trainings
      .where((t) =>
          (t.isEnrolled || t.isDefaultForAllUsers || t.isObrigatorio) &&
          t.areAllModulesCompleted &&
          !t.isApproved &&
          !t.isFailed &&
          t.enrollmentStatus != 'DROPPED')
      .toList();

  List<TrainingModel> get failedTrainings => _trainings
      .where((t) =>
          (t.isEnrolled || t.isDefaultForAllUsers || t.isObrigatorio) &&
          t.isFailed &&
          t.enrollmentStatus != 'DROPPED')
      .toList();

  List<TrainingModel> get approvedTrainings => _trainings
      .where((t) =>
          (t.isEnrolled || t.isDefaultForAllUsers || t.isObrigatorio) &&
          t.isApproved &&
          t.enrollmentStatus != 'DROPPED')
      .toList();

  List<TrainingModel> get droppedTrainings => _trainings
      .where((t) => t.enrollmentStatus == 'DROPPED')
      .toList();

  List<TrainingModel> get availableTrainings => _trainings
      .where((t) =>
          !t.isEnrolled &&
          !t.isDefaultForAllUsers &&
          !t.isObrigatorio &&
          t.enrollmentStatus != 'DROPPED')
      .toList();

  Future<void> enroll(String id) async {
    try {
      await ApiClient.instance.enrollTraining(id);
      final index = _trainings.indexWhere((t) => t.id == id);
      if (index >= 0) {
        _trainings[index] = _trainings[index].copyWith(
          isEnrolled: true,
          enrollmentStatus: 'EM_CURSO',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error enrolling in training: $e');
      rethrow;
    }
  }

  Future<void> unenroll(String id) async {
    try {
      await ApiClient.instance.unenrollTraining(id);
      final index = _trainings.indexWhere((t) => t.id == id);
      if (index >= 0) {
        _trainings[index] = _trainings[index].copyWith(
          isEnrolled: false,
          enrollmentStatus: 'DROPPED',
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error unenrolling in training: $e');
      rethrow;
    }
  }

  Future<void> deleteTraining(String id) async {
    await ApiClient.instance.deleteContent('trainings', id);
    _trainings.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
