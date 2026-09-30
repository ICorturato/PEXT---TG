class ApplicationMetadata {
  final String title;
  final String iconKey;
  final String? imageUrl;

  const ApplicationMetadata({
    required this.title,
    required this.iconKey,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'iconKey': iconKey,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  factory ApplicationMetadata.fromJson(Map<String, dynamic> json) =>
      ApplicationMetadata(
        title: (json['title'] ?? json['name'] ?? '').toString().trim(),
        iconKey: json['iconKey']?.toString() ?? 'category',
        imageUrl: json['imageUrl']?.toString(),
      );
}

class ApplicationCatalogService {
  static final Map<String, ApplicationMetadata> _registry = {};

  static void register(String title,
      {String iconKey = 'category', String? imageUrl}) {
    final key = title.trim().toLowerCase();
    if (key.isEmpty) return;
    _registry[key] = ApplicationMetadata(
      title: title.trim(),
      iconKey: iconKey,
      imageUrl: imageUrl,
    );
  }

  static ApplicationMetadata? get(String title) {
    return _registry[title.trim().toLowerCase()];
  }

  static Map<String, ApplicationMetadata> getAll() =>
      Map.unmodifiable(_registry);

  static void clear() => _registry.clear();
}

class ProductionStep {
  final String id;
  final int order;
  final String title;
  final String description;
  final String iconName;
  final String? imageUrl;

  const ProductionStep({
    required this.id,
    required this.order,
    required this.title,
    this.description = '',
    this.iconName = 'factory',
    this.imageUrl,
  });

  ProductionStep copyWith({
    String? id,
    int? order,
    String? title,
    String? description,
    String? iconName,
    String? imageUrl,
  }) =>
      ProductionStep(
        id: id ?? this.id,
        order: order ?? this.order,
        title: title ?? this.title,
        description: description ?? this.description,
        iconName: iconName ?? this.iconName,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory ProductionStep.fromJson(Map<String, dynamic> json) => ProductionStep(
        id: json['id']?.toString() ?? '',
        order: (json['order'] is num)
            ? (json['order'] as num).toInt()
            : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
        title: json['title']?.toString() ?? json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        iconName: json['iconName']?.toString() ?? 'factory',
        imageUrl: json['imageUrl']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'title': title,
        'description': description,
        'iconName': iconName,
        'imageUrl': imageUrl,
      };
}

class TechnicalDatum {
  final String id;
  final String key;
  final String value;

  const TechnicalDatum({
    required this.id,
    required this.key,
    required this.value,
  });

  TechnicalDatum copyWith({
    String? id,
    String? key,
    String? value,
  }) =>
      TechnicalDatum(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
      );

  factory TechnicalDatum.fromJson(Map<String, dynamic> json) => TechnicalDatum(
        id: json['id']?.toString() ?? '',
        key: json['key']?.toString() ?? json['name']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'value': value,
      };
}

class ResinProperty {
  final String id;
  final String name;
  final String value;
  final String level;

  const ResinProperty({
    required this.id,
    required this.name,
    this.value = '',
    this.level = 'Média',
  });

  ResinProperty copyWith({
    String? id,
    String? name,
    String? value,
    String? level,
  }) =>
      ResinProperty(
        id: id ?? this.id,
        name: name ?? this.name,
        value: value ?? this.value,
        level: level ?? this.level,
      );

  factory ResinProperty.fromJson(Map<String, dynamic> json) => ResinProperty(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['label']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
        level: json['level']?.toString() ?? 'Média',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'level': level,
      };
}

class ResinVideo {
  final String id;
  final String type; // 'YOUTUBE' | 'GALLERY'
  final String urlOrPath;
  final String title;
  final String duration;

  const ResinVideo({
    required this.id,
    required this.type,
    required this.urlOrPath,
    required this.title,
    this.duration = '',
  });

  ResinVideo copyWith({
    String? id,
    String? type,
    String? urlOrPath,
    String? title,
    String? duration,
  }) =>
      ResinVideo(
        id: id ?? this.id,
        type: type ?? this.type,
        urlOrPath: urlOrPath ?? this.urlOrPath,
        title: title ?? this.title,
        duration: duration ?? this.duration,
      );

  factory ResinVideo.fromJson(Map<String, dynamic> json) => ResinVideo(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString().toUpperCase() == 'GALLERY'
            ? 'GALLERY'
            : 'YOUTUBE',
        urlOrPath: json['urlOrPath']?.toString() ??
            json['url']?.toString() ??
            json['path']?.toString() ??
            '',
        title: json['title']?.toString() ?? '',
        duration: json['duration']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'urlOrPath': urlOrPath,
        'title': title,
        'duration': duration,
      };
}

class ResinDocument {
  final String id;
  final String name;
  final String urlOrPath;
  final String fileSize;
  final String extension;

  const ResinDocument({
    required this.id,
    required this.name,
    required this.urlOrPath,
    this.fileSize = '',
    this.extension = 'PDF',
  });

  String get url => urlOrPath;

  ResinDocument copyWith({
    String? id,
    String? name,
    String? urlOrPath,
    String? fileSize,
    String? extension,
  }) =>
      ResinDocument(
        id: id ?? this.id,
        name: name ?? this.name,
        urlOrPath: urlOrPath ?? this.urlOrPath,
        fileSize: fileSize ?? this.fileSize,
        extension: extension ?? this.extension,
      );

  factory ResinDocument.fromJson(Map<String, dynamic> json) => ResinDocument(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? json['filename']?.toString() ?? '',
        urlOrPath: json['urlOrPath']?.toString() ??
            json['url']?.toString() ??
            json['path']?.toString() ??
            '',
        fileSize: json['fileSize']?.toString() ?? json['size']?.toString() ?? '',
        extension: json['extension']?.toString() ?? 'PDF',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'urlOrPath': urlOrPath,
        'fileSize': fileSize,
        'extension': extension,
      };
}

class ResinModel {
  final String id;
  final String name;
  final String? technicalName;
  final String acronym;
  final String? categoryId;
  final String? categoryName;
  final String? subcategoryId;
  final String? subcategoryName;
  final String? imageUrl;
  final String description;
  final List<ProductionStep> productionProcess;
  final List<String> applications;
  final List<TechnicalDatum> technicalData;
  final List<ResinProperty> properties;
  final String observations;
  final List<String> mainCharacteristics;
  final List<ResinVideo> videos;
  final List<ResinDocument> documents;
  final bool isFavorite;

  const ResinModel({
    required this.id,
    required this.name,
    this.technicalName,
    required this.acronym,
    this.categoryId,
    this.categoryName,
    this.subcategoryId,
    this.subcategoryName,
    this.imageUrl,
    this.description = '',
    this.productionProcess = const [],
    this.applications = const [],
    this.technicalData = const [],
    this.properties = const [],
    this.observations = '',
    this.mainCharacteristics = const [],
    this.videos = const [],
    this.documents = const [],
    this.isFavorite = false,
  });

  String get densityMetricFormatted {
    for (final item in technicalData) {
      if (item.key.toLowerCase().contains('densidade')) {
        final val = item.value.trim();
        if (val.isEmpty) return '-';
        if (val.toLowerCase().contains('g/cm')) return val;
        return '$val g/cm³';
      }
    }
    return '-';
  }

  String get meltingPointMetricFormatted {
    for (final item in technicalData) {
      if (item.key.toLowerCase().contains('fus')) {
        final val = item.value.trim();
        if (val.isEmpty) return '-';
        if (val.contains('°C') || val.toUpperCase().contains('C')) return val;
        return '$val °C';
      }
    }
    return '-';
  }

  String get mfiMetricFormatted {
    for (final item in technicalData) {
      final k = item.key.toLowerCase();
      if (k.contains('mfi') || k.contains('flu')) {
        final val = item.value.trim();
        if (val.isEmpty) return '-';
        if (val.toLowerCase().contains('g/10') || val.toLowerCase().contains('min')) return val;
        return '$val g/10 min';
      }
    }
    return '-';
  }

  ResinModel copyWith({
    String? id,
    String? name,
    String? technicalName,
    String? acronym,
    String? categoryId,
    String? categoryName,
    String? subcategoryId,
    String? subcategoryName,
    String? imageUrl,
    String? description,
    List<ProductionStep>? productionProcess,
    List<String>? applications,
    List<TechnicalDatum>? technicalData,
    List<ResinProperty>? properties,
    String? observations,
    List<String>? mainCharacteristics,
    List<ResinVideo>? videos,
    List<ResinDocument>? documents,
    bool? isFavorite,
  }) =>
      ResinModel(
        id: id ?? this.id,
        name: name ?? this.name,
        technicalName: technicalName ?? this.technicalName,
        acronym: acronym ?? this.acronym,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        subcategoryId: subcategoryId ?? this.subcategoryId,
        subcategoryName: subcategoryName ?? this.subcategoryName,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
        productionProcess: productionProcess ?? this.productionProcess,
        applications: applications ?? this.applications,
        technicalData: technicalData ?? this.technicalData,
        properties: properties ?? this.properties,
        observations: observations ?? this.observations,
        mainCharacteristics: mainCharacteristics ?? this.mainCharacteristics,
        videos: videos ?? this.videos,
        documents: documents ?? this.documents,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  factory ResinModel.fromJson(Map<String, dynamic> json,
      {bool isFavorite = false, String? categoryName}) {
    // Process flowchart steps
    final rawProcess =
        json['productionProcess'] ?? json['productionProcesses'];
    final List<ProductionStep> processSteps = [];
    if (rawProcess is List) {
      for (var i = 0; i < rawProcess.length; i++) {
        final item = rawProcess[i];
        if (item is Map) {
          processSteps.add(ProductionStep.fromJson(
              Map<String, dynamic>.from(item)));
        } else if (item is String && item.trim().isNotEmpty) {
          processSteps.add(ProductionStep(
            id: 'step_$i',
            order: i + 1,
            title: item.trim(),
          ));
        }
      }
    }

    // Applications tags
    final rawApps = json['applications'];
    final List<String> appsList = [];
    if (rawApps is List) {
      for (final item in rawApps) {
        if (item is Map && (item['title'] != null || item['name'] != null)) {
          final t = (item['title'] ?? item['name']).toString().trim();
          if (t.isNotEmpty) {
            appsList.add(t);
            ApplicationCatalogService.register(
              t,
              iconKey: item['iconKey']?.toString() ?? 'category',
              imageUrl: item['imageUrl']?.toString(),
            );
          }
        } else if (item != null && item.toString().trim().isNotEmpty) {
          appsList.add(item.toString().trim());
        }
      }
    }

    // Technical data
    final rawTech = json['technicalData'];
    final List<TechnicalDatum> techList = [];
    if (rawTech is List) {
      for (final item in rawTech) {
        if (item is Map) {
          techList.add(TechnicalDatum.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawTech is Map) {
      rawTech.forEach((k, v) {
        techList.add(TechnicalDatum(
            id: k.toString(), key: k.toString(), value: v?.toString() ?? ''));
      });
    }

    // Properties
    final rawProps = json['properties'];
    final List<ResinProperty> propsList = [];
    if (rawProps is List) {
      for (final item in rawProps) {
        if (item is Map) {
          propsList.add(ResinProperty.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawProps is Map) {
      final levels = rawProps['levels'];
      if (levels is Map) {
        levels.forEach((k, v) {
          final levelStr = switch (v) {
            0 => 'Baixa',
            1 => 'Média',
            2 => 'Alta',
            _ => v?.toString() ?? 'Média',
          };
          propsList.add(ResinProperty(
              id: k.toString(), name: k.toString(), level: levelStr));
        });
      }
    }

    // Main Characteristics chips
    final rawMainChars = json['mainCharacteristics'];
    final List<String> mainCharsList = [];
    if (rawMainChars is List) {
      for (final item in rawMainChars) {
        if (item != null && item.toString().trim().isNotEmpty) {
          mainCharsList.add(item.toString().trim());
        }
      }
    }

    // Videos
    final rawVideos = json['videos'];
    final List<ResinVideo> videosList = [];
    if (rawVideos is List) {
      for (final item in rawVideos) {
        if (item is Map) {
          videosList.add(ResinVideo.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // Documents
    final rawDocs = json['documents'];
    final List<ResinDocument> docsList = [];
    if (rawDocs is List) {
      for (final item in rawDocs) {
        if (item is Map) {
          docsList.add(ResinDocument.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final catId = json['categoryId']?.toString();
    final catName = categoryName ??
        json['categoryName']?.toString() ??
        json['category']?.toString();

    return ResinModel(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['fullName'])?.toString() ?? '',
      technicalName: json['technicalName']?.toString(),
      acronym: (json['acronym'] ?? json['code'])?.toString() ?? '',
      categoryId: catId,
      categoryName: catName,
      subcategoryId: json['subcategoryId']?.toString(),
      subcategoryName: json['subcategoryName']?.toString(),
      imageUrl: (json['imageUrl'] ?? json['imagePath'])?.toString(),
      description:
          (json['description'] ?? json['overview'])?.toString() ?? '',
      productionProcess: processSteps,
      applications: appsList,
      technicalData: techList,
      properties: propsList,
      observations: json['observations']?.toString() ?? '',
      mainCharacteristics: mainCharsList,
      videos: videosList,
      documents: docsList,
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fullName': name,
        'technicalName': technicalName,
        'acronym': acronym,
        'code': acronym,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'subcategoryId': subcategoryId,
        'subcategoryName': subcategoryName,
        'imageUrl': imageUrl,
        'imagePath': imageUrl,
        'description': description,
        'overview': description,
        'productionProcess':
            productionProcess.map((item) => item.toJson()).toList(),
        'productionProcesses':
            productionProcess.map((item) => item.toJson()).toList(),
        'applications': applications.map((app) {
          final meta = ApplicationCatalogService.get(app);
          if (meta != null &&
              (meta.imageUrl != null ||
                  (meta.iconKey.isNotEmpty && meta.iconKey != 'category'))) {
            return {
              'title': meta.title,
              'iconKey': meta.iconKey,
              if (meta.imageUrl != null) 'imageUrl': meta.imageUrl,
            };
          }
          return app;
        }).toList(),
        'technicalData':
            technicalData.map((item) => item.toJson()).toList(),
        'properties': properties.map((item) => item.toJson()).toList(),
        'observations': observations,
        'mainCharacteristics': mainCharacteristics,
        'videos': videos.map((item) => item.toJson()).toList(),
        'documents': documents.map((item) => item.toJson()).toList(),
      };
}
