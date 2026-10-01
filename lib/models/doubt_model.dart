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

class VerificationParameterItem {
  final String parameterName;
  final String target;
  final String measuredValue;
  final String deviation;
  final bool? explicitIsWithinRange;

  const VerificationParameterItem({
    required this.parameterName,
    required this.target,
    required this.measuredValue,
    required this.deviation,
    this.explicitIsWithinRange,
  });

  bool get isWithinRange {
    if (explicitIsWithinRange != null) return explicitIsWithinRange!;
    try {
      final targetParts = target.split('-');
      if (targetParts.length >= 2) {
        final minStr = targetParts[0].replaceAll(RegExp(r'[^0-9\.\-]'), '').trim();
        final maxStr = targetParts[1].replaceAll(RegExp(r'[^0-9\.\-]'), '').trim();
        final measStr = measuredValue.replaceAll(RegExp(r'[^0-9\.\-]'), '').trim();
        final min = double.tryParse(minStr);
        final max = double.tryParse(maxStr);
        final meas = double.tryParse(measStr);
        if (min != null && max != null && meas != null) {
          return meas >= min && meas <= max;
        }
      }
    } catch (_) {}

    final devStr = deviation.replaceAll(RegExp(r'[^0-9\.\-]'), '').trim();
    final devVal = double.tryParse(devStr);
    if (devVal != null && devVal.abs() < 0.001) return true;
    return deviation.trim() == '0' ||
        deviation.trim() == '0.0' ||
        deviation.trim() == '+0.0' ||
        deviation.trim().isEmpty;
  }

  factory VerificationParameterItem.fromJson(Map<String, dynamic> json) =>
      VerificationParameterItem(
        parameterName: json['parameterName']?.toString() ??
            json['name']?.toString() ??
            '',
        target: json['target']?.toString() ?? '-',
        measuredValue: json['measuredValue']?.toString() ??
            json['measured']?.toString() ??
            '-',
        deviation: json['deviation']?.toString() ?? '-',
        explicitIsWithinRange: json['isWithinRange'] is bool
            ? json['isWithinRange'] as bool
            : (json['isWithinRange'] != null
                ? json['isWithinRange'].toString().toLowerCase() == 'true'
                : null),
      );

  Map<String, dynamic> toJson() => {
        'parameterName': parameterName,
        'target': target,
        'measuredValue': measuredValue,
        'deviation': deviation,
        'isWithinRange': isWithinRange,
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

  bool get isFinalized =>
      status.toUpperCase() == 'FINALIZADO' ||
      status.toUpperCase() == 'RESOLVED' ||
      status.toUpperCase() == 'CONCLUIDO' ||
      status.toUpperCase() == 'CONCLUÍDO';

  bool get isInProgress =>
      status.toUpperCase() == 'IN_PROGRESS' ||
      status.toUpperCase() == 'EM_ANDAMENTO' ||
      status.toUpperCase() == 'RESPONDIDO' ||
      status.toUpperCase() == 'RESPONDIDA';

  bool get isOpen => !isFinalized && !isInProgress;

  bool get isAnswered => isInProgress || isFinalized;

  List<VerificationParameterItem> get parsedVerificationParameters {
    if (verificationData == null) return const [];
    final rawParams = verificationData!['parameters'];
    if (rawParams is List) {
      return rawParams
          .whereType<Map>()
          .map((p) => VerificationParameterItem.fromJson(
              Map<String, dynamic>.from(p)))
          .toList();
    }
    final result = <VerificationParameterItem>[];
    for (final entry in verificationData!.entries) {
      if (entry.key == 'parameters' || entry.key == 'packagingId' || entry.key == 'packaging') continue;
      if (entry.value is Map) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['parameterName'] ??= entry.key;
        result.add(VerificationParameterItem.fromJson(val));
      }
    }
    return result;
  }

  String? get targetPackagingName {
    if (verificationData == null) return null;
    return verificationData!['packagingId']?.toString() ??
        verificationData!['packaging']?.toString() ??
        verificationData!['packagingName']?.toString();
  }

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
