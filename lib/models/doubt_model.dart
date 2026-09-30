class DoubtMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'ADMIN', 'USER'
  final String text;
  final String? avatarUrl;
  final String createdAt;

  const DoubtMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    this.avatarUrl,
    required this.createdAt,
  });

  bool get isAdmin => senderRole == 'ADMIN';

  factory DoubtMessage.fromJson(Map<String, dynamic> json) => DoubtMessage(
        id: json['id']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        senderName: json['senderName']?.toString() ?? 'Usuário',
        senderRole: json['senderRole']?.toString() ?? 'USER',
        text: json['text']?.toString() ?? '',
        avatarUrl: json['avatarUrl']?.toString(),
        createdAt: json['createdAt']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'senderRole': senderRole,
        'text': text,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'createdAt': createdAt,
      };
}

class DoubtModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String question;
  final String status; // 'RESPONDIDO', 'NAO_RESPONDIDO'
  final String createdAt;
  final String? machineId;
  final String? processContext;
  final String? description;
  final Map<String, dynamic>? verificationData;
  final List<DoubtMessage> messages;

  const DoubtModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.question,
    this.status = 'NAO_RESPONDIDO',
    required this.createdAt,
    this.machineId,
    this.processContext,
    this.description,
    this.verificationData,
    this.messages = const [],
  });

  bool get isAnswered => status == 'RESPONDIDO';

  factory DoubtModel.fromJson(Map<String, dynamic> json) => DoubtModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        userName: json['userName']?.toString() ?? 'Igor Teixeira Corturato',
        userAvatarUrl: json['userAvatarUrl']?.toString(),
        question: json['question']?.toString() ?? json['description']?.toString() ?? '',
        status: json['status']?.toString() ?? 'NAO_RESPONDIDO',
        createdAt: json['createdAt']?.toString() ?? '',
        machineId: json['machineId']?.toString(),
        processContext: json['processContext']?.toString(),
        description: json['description']?.toString(),
        verificationData: json['verificationData'] != null
            ? Map<String, dynamic>.from(json['verificationData'] as Map)
            : null,
        messages: (json['messages'] as List? ?? [])
            .map((e) => DoubtMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
        'question': question,
        'status': status,
        'createdAt': createdAt,
        if (machineId != null) 'machineId': machineId,
        if (processContext != null) 'processContext': processContext,
        if (description != null) 'description': description,
        if (verificationData != null) 'verificationData': verificationData,
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  DoubtModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? question,
    String? status,
    String? createdAt,
    String? machineId,
    String? processContext,
    String? description,
    Map<String, dynamic>? verificationData,
    List<DoubtMessage>? messages,
  }) =>
      DoubtModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
        question: question ?? this.question,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        machineId: machineId ?? this.machineId,
        processContext: processContext ?? this.processContext,
        description: description ?? this.description,
        verificationData: verificationData ?? this.verificationData,
        messages: messages ?? this.messages,
      );
}
