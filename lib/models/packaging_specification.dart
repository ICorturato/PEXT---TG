class PackagingParameter {
  final String name;
  final String unit;
  double min;
  double max;
  bool enabled;
  final bool isCustom;

  PackagingParameter({
    required this.name,
    required this.unit,
    required this.min,
    required this.max,
    this.enabled = true,
    this.isCustom = false,
  });

  factory PackagingParameter.fromJson(Map<String, dynamic> json) =>
      PackagingParameter(
          name: json['name']?.toString() ?? '',
          unit: json['unit']?.toString() ?? '',
          min: (json['min'] as num?)?.toDouble() ?? 0,
          max: (json['max'] as num?)?.toDouble() ?? 0,
          enabled: json['enabled'] as bool? ?? true,
          isCustom: json['isCustom'] as bool? ?? false);
}

class PackagingSpecification {
  final String name;
  final List<PackagingParameter> parameters;
  final List<PackagingParameter> extraParameters;

  PackagingSpecification(
      {required this.name,
      List<PackagingParameter>? parameters,
      List<PackagingParameter>? extraParameters})
      : parameters = List<PackagingParameter>.from(parameters ?? const []),
        extraParameters =
            List<PackagingParameter>.from(extraParameters ?? const []);

  factory PackagingSpecification.fromJson(Map<String, dynamic> json) =>
      PackagingSpecification(
          name: json['name']?.toString() ?? '',
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
}

/// In-memory catalog used by the prototype until the packaging API is wired.
class PackagingCatalog {
  static final List<PackagingSpecification> items = [
    PackagingSpecification(name: 'RAP10', parameters: _parameters()),
    PackagingSpecification(name: 'Macarrão', parameters: _parameters()),
    PackagingSpecification(name: 'KitKat', parameters: _parameters()),
  ];

  static PackagingSpecification byName(String name) =>
      items.firstWhere((item) => item.name == name, orElse: () => items.first);

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
