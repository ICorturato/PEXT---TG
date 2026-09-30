class ContentAuditEntry {
  final String id;
  final String authorName;
  final String authorRole;
  final String action; // 'CREATE', 'UPDATE', 'DELETE'
  final String date;
  final String title;
  final String description;
  final Map<String, dynamic>? previousContent;

  const ContentAuditEntry({
    required this.id,
    required this.authorName,
    this.authorRole = 'ADMIN',
    required this.action,
    required this.date,
    required this.title,
    required this.description,
    this.previousContent,
  });

  factory ContentAuditEntry.fromJson(Map<String, dynamic> json) =>
      ContentAuditEntry(
        id: json['id']?.toString() ?? '',
        authorName: json['authorName']?.toString() ?? 'Administrador',
        authorRole: json['authorRole']?.toString() ?? 'ADMIN',
        action: json['action']?.toString() ?? 'UPDATE',
        date: json['date']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        previousContent: json['previousContent'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorName': authorName,
        'authorRole': authorRole,
        'action': action,
        'date': date,
        'title': title,
        'description': description,
        if (previousContent != null) 'previousContent': previousContent,
      };
}

class ContentModel {
  final String id;
  final String title;
  final String text;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? documentName;
  final String? documentUrl;
  final String? documentSize;
  final String authorName;
  final String? authorId;
  final String status; // 'ATIVO', 'INACTIVE', 'EXCLUIDO'
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;
  final List<ContentAuditEntry> history;

  const ContentModel({
    required this.id,
    required this.title,
    required this.text,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.documentName,
    this.documentUrl,
    this.documentSize,
    required this.authorName,
    this.authorId,
    this.status = 'ATIVO',
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.history = const [],
  });

  bool get isActive {
    if (isDeleted) return false;
    final s = status.trim().toUpperCase();
    return s == 'ATIVO' || s == 'ACTIVE';
  }

  bool get isInactive => !isActive;

  factory ContentModel.fromJson(Map<String, dynamic> json) => ContentModel(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        categoryId: json['categoryId']?.toString(),
        categoryName: json['categoryName']?.toString(),
        categoryIcon: json['categoryIcon']?.toString(),
        documentName: json['documentName']?.toString(),
        documentUrl: json['documentUrl']?.toString(),
        documentSize: json['documentSize']?.toString(),
        authorName: json['authorName']?.toString() ?? 'André',
        authorId: json['authorId']?.toString(),
        status: json['status']?.toString() ?? 'ATIVO',
        isDeleted: json['is_deleted'] == true ||
            json['isDeleted'] == true ||
            json['status'] == 'INACTIVE' ||
            json['status'] == 'EXCLUIDO',
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
        history: (json['history'] as List? ?? [])
            .map((e) => ContentAuditEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'text': text,
        if (categoryId != null) 'categoryId': categoryId,
        if (categoryName != null) 'categoryName': categoryName,
        if (categoryIcon != null) 'categoryIcon': categoryIcon,
        if (documentName != null) 'documentName': documentName,
        if (documentUrl != null) 'documentUrl': documentUrl,
        if (documentSize != null) 'documentSize': documentSize,
        'authorName': authorName,
        if (authorId != null) 'authorId': authorId,
        'status': status,
        'is_deleted': isDeleted,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'history': history.map((e) => e.toJson()).toList(),
      };

  ContentModel copyWith({
    String? id,
    String? title,
    String? text,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? documentName,
    String? documentUrl,
    String? documentSize,
    String? authorName,
    String? authorId,
    String? status,
    bool? isDeleted,
    String? createdAt,
    String? updatedAt,
    List<ContentAuditEntry>? history,
  }) =>
      ContentModel(
        id: id ?? this.id,
        title: title ?? this.title,
        text: text ?? this.text,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        categoryIcon: categoryIcon ?? this.categoryIcon,
        documentName: documentName ?? this.documentName,
        documentUrl: documentUrl ?? this.documentUrl,
        documentSize: documentSize ?? this.documentSize,
        authorName: authorName ?? this.authorName,
        authorId: authorId ?? this.authorId,
        status: status ?? this.status,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        history: history ?? this.history,
      );
}
