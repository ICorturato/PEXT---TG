enum CategoryScope { resin, training, terms, problem, content, packaging }

extension CategoryScopeApi on CategoryScope {
  String get value => switch (this) {
        CategoryScope.resin => 'RESIN',
        CategoryScope.training => 'TRAINING',
        CategoryScope.terms => 'TERMS',
        CategoryScope.problem => 'PROBLEM',
        CategoryScope.content => 'CONTENT',
        CategoryScope.packaging => 'PACKAGING',
      };

  String get label => switch (this) {
        CategoryScope.resin => 'Resinas',
        CategoryScope.training => 'Treinamentos',
        CategoryScope.terms => 'Termos',
        CategoryScope.problem => 'Problemas',
        CategoryScope.content => 'Conteúdo',
        CategoryScope.packaging => 'Embalagens',
      };
}

class AppCategory {
  final String id;
  final String name;
  final CategoryScope scope;
  final String? imageUrl;
  final String? iconKey;

  const AppCategory({
    required this.id,
    required this.name,
    required this.scope,
    this.imageUrl,
    this.iconKey,
  });

  factory AppCategory.fromJson(Map<String, dynamic> json) {
    final value = json['scope']?.toString() ?? 'TERMS';
    final scope = CategoryScope.values.firstWhere(
      (item) => item.value == value,
      orElse: () => CategoryScope.terms,
    );
    return AppCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      scope: scope,
      imageUrl: json['imageUrl']?.toString(),
      iconKey: json['iconKey']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scope': scope.value,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (iconKey != null) 'iconKey': iconKey,
      };
}
