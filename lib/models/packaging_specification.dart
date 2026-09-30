class PackagingParameter {
  final String? id;
  final String name;
  final String unit;
  double min;
  double max;
  bool enabled;
  final bool isCustom;

  PackagingParameter({
    this.id,
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
    this.enabled = true,
    this.isCustom = false,
  });

  factory PackagingParameter.fromJson(Map<String, dynamic> json) =>
      PackagingParameter(
          id: json['id']?.toString(),
          name: json['name']?.toString() ?? '',
          unit: json['unit']?.toString() ?? '',
          min: ((json['minValue'] ?? json['min']) as num?)?.toDouble() ?? 0,
          max: ((json['maxValue'] ?? json['max']) as num?)?.toDouble() ?? 0,
          enabled: (json['isEnabled'] ?? json['enabled']) as bool? ?? true,
          isCustom: (json['type'] == 'EXTRA') ||
              (json['isCustom'] as bool? ?? false));

  Map<String, dynamic> toApiJson() => {
        'name': name,
        'unit': unit,
        'minValue': min,
        'maxValue': max,
        'type': isCustom ? 'EXTRA' : 'FIXED',
        'isEnabled': enabled,
      };
}

typedef PackagingModel = PackagingSpecification;

class PackagingSpecification {
  final String? id;
  final String name;
  final String? category;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? imageUrl;
  final List<PackagingParameter> parameters;
  final List<PackagingParameter> extraParameters;

  PackagingSpecification(
      {this.id,
      required this.name,
      this.category,
      this.categoryId,
      this.categoryName,
      this.categoryIcon,
      this.imageUrl,
      List<PackagingParameter>? parameters,
      List<PackagingParameter>? extraParameters})
      : parameters = List<PackagingParameter>.from(parameters ?? const []),
        extraParameters =
            List<PackagingParameter>.from(extraParameters ?? const []);

  factory PackagingSpecification.fromJson(Map<String, dynamic> json) =>
      PackagingSpecification(
          id: json['id']?.toString(),
          name: json['name']?.toString() ?? '',
          category: json['category']?.toString() ?? json['categoryName']?.toString(),
          categoryId: json['categoryId']?.toString(),
          categoryName: json['categoryName']?.toString() ?? json['category']?.toString(),
          categoryIcon: json['categoryIcon']?.toString(),
          imageUrl: json['imageUrl']?.toString(),
          parameters: (json['parameters'] as List?)
                  ?.whereType<Map>()
                  .map((item) => PackagingParameter.fromJson(
                      Map<String, dynamic>.from(item)))
                  .toList(growable: true) ??
              <PackagingParameter>[],
          extraParameters: (json['extraParameters'] as List?)
                  ?.whereType<Map>()
                  .map((item) => PackagingParameter.fromJson(
                      Map<String, dynamic>.from(item)))
                  .toList(growable: true) ??
              <PackagingParameter>[]);

  Iterable<PackagingParameter> get enabledVerifications => [
        ...parameters.where((parameter) => parameter.enabled),
        ...extraParameters.where((parameter) => parameter.enabled),
      ];

  Iterable<PackagingParameter> get allParameters =>
      [...parameters, ...extraParameters];
}

/// In-memory catalog used by the prototype until the packaging API is wired.
class PackagingCatalog {
  static final List<PackagingSpecification> items = [
    PackagingSpecification(
        name: 'RAP10',
        imageUrl: '/uploads/bbbf56b8-7cab-4b76-8ea9-4ed9e379ebee.jpg',
        parameters: _parameters()),
    PackagingSpecification(
        name: 'Macarrão',
        imageUrl: '/uploads/7edaf146-b926-4c3b-8ff6-c598feca65f4.jpg',
        parameters: _parameters()),
    PackagingSpecification(
        name: 'KitKat',
        imageUrl: '/uploads/bbbf56b8-7cab-4b76-8ea9-4ed9e379ebee.jpg',
        parameters: _parameters()),
  ];

  static PackagingSpecification byName(String name) =>
      items.firstWhere((item) => item.name == name, orElse: () => items.first);

  static void replace(Iterable<PackagingSpecification> values) {
    items
      ..clear()
      ..addAll(values);
  }

  static List<PackagingParameter> _parameters() => [
        PackagingParameter(
            name: 'Temperatura do cilindro', unit: '°C', min: 160, max: 180),
        PackagingParameter(
            name: 'Velocidade da linha', unit: 'm/min', min: 20, max: 35),
        PackagingParameter(
            name: 'Pressão do sistema', unit: 'bar', min: 70, max: 90),
        PackagingParameter(
            name: 'Espessura da matriz', unit: 'mm', min: 0.04, max: 0.06),
      ];
}
