class TrainingVideo {
  final String id;
  final String title;
  final String duration;
  final String urlOrPath;
  final String? thumbnailUrl;

  const TrainingVideo({
    required this.id,
    required this.title,
    this.duration = '03:20',
    required this.urlOrPath,
    this.thumbnailUrl,
  });

  factory TrainingVideo.fromJson(Map<String, dynamic> json) => TrainingVideo(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Vídeo sem título',
        duration: json['duration']?.toString() ?? '03:20',
        urlOrPath: json['urlOrPath']?.toString() ?? '',
        thumbnailUrl: json['thumbnailUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'duration': duration,
        'urlOrPath': urlOrPath,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      };
}

class TrainingDocument {
  final String id;
  final String title;
  final String fileSize;
  final String extension;
  final String urlOrPath;

  const TrainingDocument({
    required this.id,
    required this.title,
    this.fileSize = 'PDF - 1,2 MB',
    this.extension = 'PDF',
    required this.urlOrPath,
  });

  factory TrainingDocument.fromJson(Map<String, dynamic> json) =>
      TrainingDocument(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Documento sem título',
        fileSize: json['fileSize']?.toString() ?? 'PDF - 1,2 MB',
        extension: json['extension']?.toString() ?? 'PDF',
        urlOrPath: json['urlOrPath']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fileSize': fileSize,
        'extension': extension,
        'urlOrPath': urlOrPath,
      };
}

class TrainingModule {
  final String id;
  final int order;
  final String title;
  final String description;
  final List<TrainingVideo> videos;
  final List<TrainingDocument> documents;
  final bool isCompleted;
  final bool isVideoWatched;
  final bool isDocumentOpened;

  const TrainingModule({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    this.videos = const [],
    this.documents = const [],
    this.isCompleted = false,
    this.isVideoWatched = false,
    this.isDocumentOpened = false,
  });

  bool get isFullyCompleted =>
      isCompleted ||
      ((videos.isNotEmpty || documents.isNotEmpty) &&
          (videos.isEmpty || isVideoWatched) &&
          (documents.isEmpty || isDocumentOpened));

  TrainingModule copyWith({
    String? id,
    int? order,
    String? title,
    String? description,
    List<TrainingVideo>? videos,
    List<TrainingDocument>? documents,
    bool? isCompleted,
    bool? isVideoWatched,
    bool? isDocumentOpened,
  }) =>
      TrainingModule(
        id: id ?? this.id,
        order: order ?? this.order,
        title: title ?? this.title,
        description: description ?? this.description,
        videos: videos ?? this.videos,
        documents: documents ?? this.documents,
        isCompleted: isCompleted ?? this.isCompleted,
        isVideoWatched: isVideoWatched ?? this.isVideoWatched,
        isDocumentOpened: isDocumentOpened ?? this.isDocumentOpened,
      );

  factory TrainingModule.fromJson(Map<String, dynamic> json) => TrainingModule(
        id: json['id']?.toString() ?? '',
        order: (json['order'] as num?)?.toInt() ?? 1,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        videos: (json['videos'] as List?)
                ?.map((e) => TrainingVideo.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        documents: (json['documents'] as List?)
                ?.map((e) => TrainingDocument.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
        isCompleted: json['isCompleted'] == true,
        isVideoWatched: json['isVideoWatched'] == true,
        isDocumentOpened: json['isDocumentOpened'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'title': title,
        'description': description,
        'videos': videos.map((v) => v.toJson()).toList(),
        'documents': documents.map((d) => d.toJson()).toList(),
        'isCompleted': isCompleted,
        'isVideoWatched': isVideoWatched,
        'isDocumentOpened': isDocumentOpened,
      };
}

class TrainingAlternative {
  final String id;
  final String letter;
  final String text;
  final bool isCorrect;

  const TrainingAlternative({
    required this.id,
    required this.letter,
    required this.text,
    this.isCorrect = false,
  });

  TrainingAlternative copyWith({
    String? id,
    String? letter,
    String? text,
    bool? isCorrect,
  }) =>
      TrainingAlternative(
        id: id ?? this.id,
        letter: letter ?? this.letter,
        text: text ?? this.text,
        isCorrect: isCorrect ?? this.isCorrect,
      );

  factory TrainingAlternative.fromJson(Map<String, dynamic> json) =>
      TrainingAlternative(
        id: json['id']?.toString() ?? '',
        letter: json['letter']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        isCorrect: json['isCorrect'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'letter': letter,
        'text': text,
        'isCorrect': isCorrect,
      };
}

class TrainingQuestion {
  final String id;
  final int order;
  final String prompt;
  final String type; // 'SINGLE_CHOICE', 'TRUE_FALSE', 'MULTIPLE_CHOICE'
  final String? imageUrl;
  final List<TrainingAlternative> alternatives;

  const TrainingQuestion({
    required this.id,
    required this.order,
    required this.prompt,
    this.type = 'SINGLE_CHOICE',
    this.imageUrl,
    this.alternatives = const [],
  });

  TrainingQuestion copyWith({
    String? id,
    int? order,
    String? prompt,
    String? type,
    String? imageUrl,
    List<TrainingAlternative>? alternatives,
  }) =>
      TrainingQuestion(
        id: id ?? this.id,
        order: order ?? this.order,
        prompt: prompt ?? this.prompt,
        type: type ?? this.type,
        imageUrl: imageUrl ?? this.imageUrl,
        alternatives: alternatives ?? this.alternatives,
      );

  factory TrainingQuestion.fromJson(Map<String, dynamic> json) =>
      TrainingQuestion(
        id: json['id']?.toString() ?? '',
        order: (json['order'] as num?)?.toInt() ?? 1,
        prompt: json['prompt']?.toString() ?? '',
        type: json['type']?.toString() ?? 'SINGLE_CHOICE',
        imageUrl: json['imageUrl']?.toString(),
        alternatives: (json['alternatives'] as List?)
                ?.map((e) => TrainingAlternative.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'prompt': prompt,
        'type': type,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'alternatives': alternatives.map((a) => a.toJson()).toList(),
      };
}

class TrainingModel {
  final String id;
  final String title;
  final String description;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? workload;
  final String? thumbnailUrl;
  final int passingGrade;
  final int questionCount;
  final List<TrainingModule> modules;
  final List<TrainingQuestion> questions;
  final int totalSteps;
  final bool isDefaultForAllUsers;
  final bool isEnrolled;
  final String? enrollmentStatus;
  final int? scorePercentage;
  final int? correctCount;
  final int? totalQuestionsCount;
  final String? assessmentStatus;
  final String? createdAt;
  final String? updatedAt;

  const TrainingModel({
    required this.id,
    required this.title,
    required this.description,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.workload,
    this.thumbnailUrl,
    this.passingGrade = 70,
    this.questionCount = 35,
    this.modules = const [],
    this.questions = const [],
    this.totalSteps = 0,
    this.isDefaultForAllUsers = true,
    this.isEnrolled = false,
    this.enrollmentStatus,
    this.scorePercentage,
    this.correctCount,
    this.totalQuestionsCount,
    this.assessmentStatus,
    this.createdAt,
    this.updatedAt,
  });

  int get completedModuleCount =>
      modules.where((m) => m.isCompleted || m.isFullyCompleted).length;

  int get completedModulesCount => completedModuleCount;

  int get totalModulesCount => modules.length;

  int get inProgressModuleCount =>
      modules.isNotEmpty && completedModuleCount < modules.length ? 1 : 0;

  int get notStartedModuleCount {
    final remaining = modules.length - completedModuleCount - inProgressModuleCount;
    return remaining > 0 ? remaining : 0;
  }

  double get progressPercentage => modules.isEmpty
      ? 0.0
      : (completedModuleCount / modules.length).clamp(0.0, 1.0);

  bool get areAllModulesCompleted =>
      modules.isNotEmpty && completedModuleCount == modules.length;

  bool get isObrigatorio => isDefaultForAllUsers;

  bool get isApproved =>
      scorePercentage != null && scorePercentage! >= passingGrade;

  bool get isFailed =>
      enrollmentStatus?.toUpperCase() == 'REPROVADO' ||
      (scorePercentage != null && scorePercentage! < passingGrade);

  bool get isAwaitingAssessment =>
      areAllModulesCompleted && scorePercentage == null && !isFailed;

  TrainingModule? get nextIncompleteModule {
    for (final m in modules) {
      if (!m.isCompleted && !m.isFullyCompleted) return m;
    }
    return modules.isNotEmpty ? modules.first : null;
  }

  TrainingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? workload,
    String? thumbnailUrl,
    int? passingGrade,
    int? questionCount,
    List<TrainingModule>? modules,
    List<TrainingQuestion>? questions,
    int? totalSteps,
    bool? isDefaultForAllUsers,
    bool? isEnrolled,
    String? enrollmentStatus,
    int? scorePercentage,
    int? correctCount,
    int? totalQuestionsCount,
    String? assessmentStatus,
    String? createdAt,
    String? updatedAt,
  }) =>
      TrainingModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        categoryIcon: categoryIcon ?? this.categoryIcon,
        workload: workload ?? this.workload,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        passingGrade: passingGrade ?? this.passingGrade,
        questionCount: questionCount ?? this.questionCount,
        modules: modules ?? this.modules,
        questions: questions ?? this.questions,
        totalSteps: totalSteps ?? this.totalSteps,
        isDefaultForAllUsers: isDefaultForAllUsers ?? this.isDefaultForAllUsers,
        isEnrolled: isEnrolled ?? this.isEnrolled,
        enrollmentStatus: enrollmentStatus ?? this.enrollmentStatus,
        scorePercentage: scorePercentage ?? this.scorePercentage,
        correctCount: correctCount ?? this.correctCount,
        totalQuestionsCount: totalQuestionsCount ?? this.totalQuestionsCount,
        assessmentStatus: assessmentStatus ?? this.assessmentStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    final prog = json['progress'] is Map ? json['progress'] as Map : null;
    return TrainingModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      categoryIcon: json['categoryIcon']?.toString(),
      workload: json['workload']?.toString() ?? json['duration']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? json['imageUrl']?.toString(),
      passingGrade: (json['passingGrade'] as num?)?.toInt() ?? 70,
      questionCount: (json['questionCount'] as num?)?.toInt() ??
          (json['totalSteps'] as num?)?.toInt() ??
          35,
      totalSteps: (json['totalSteps'] as num?)?.toInt() ?? 0,
      isDefaultForAllUsers: json['isDefaultForAllUsers'] != false,
      isEnrolled: json['isEnrolled'] == true,
      enrollmentStatus: json['enrollmentStatus']?.toString() ??
          prog?['status']?.toString(),
      scorePercentage: (json['scorePercentage'] as num?)?.toInt() ??
          (prog?['scorePercentage'] as num?)?.toInt(),
      correctCount: (json['correctCount'] as num?)?.toInt() ??
          (prog?['correctCount'] as num?)?.toInt(),
      totalQuestionsCount: (json['totalCount'] as num?)?.toInt() ??
          (prog?['totalCount'] as num?)?.toInt(),
      assessmentStatus: json['assessmentStatus']?.toString() ??
          prog?['status']?.toString(),
      modules: (json['modules'] as List?)
              ?.map((e) => TrainingModule.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      questions: (json['questions'] as List?)
              ?.map((e) => TrainingQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        if (categoryId != null) 'categoryId': categoryId,
        if (categoryName != null) 'categoryName': categoryName,
        if (categoryIcon != null) 'categoryIcon': categoryIcon,
        if (workload != null) 'workload': workload,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'passingGrade': passingGrade,
        'questionCount': questionCount,
        'totalSteps': totalSteps,
        'isDefaultForAllUsers': isDefaultForAllUsers,
        if (scorePercentage != null) 'scorePercentage': scorePercentage,
        if (correctCount != null) 'correctCount': correctCount,
        if (totalQuestionsCount != null) 'totalCount': totalQuestionsCount,
        if (assessmentStatus != null) 'assessmentStatus': assessmentStatus,
        'modules': modules.map((m) => m.toJson()).toList(),
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}
