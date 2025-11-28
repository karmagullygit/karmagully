enum MessageType {
  user,
  bot,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.attachments,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.user,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments,
      'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ChatConversation {
  final String id;
  final String userId;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime lastMessageAt;
  final bool isActive;

  ChatConversation({
    required this.id,
    required this.userId,
    this.title = 'New Chat',
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
    this.isActive = true,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? 'New Chat',
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((msg) => ChatMessage.fromJson(msg))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastMessageAt: DateTime.parse(json['lastMessageAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class BotResponse {
  final String content;
  final List<String>? quickReplies;
  final Map<String, dynamic>? actions;
  final int confidence;

  BotResponse({
    required this.content,
    this.quickReplies,
    this.actions,
    this.confidence = 100,
  });

  factory BotResponse.fromJson(Map<String, dynamic> json) {
    return BotResponse(
      content: json['content'] ?? '',
      quickReplies: json['quickReplies'] != null 
          ? List<String>.from(json['quickReplies']) 
          : null,
      actions: json['actions'],
      confidence: json['confidence'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'quickReplies': quickReplies,
      'actions': actions,
      'confidence': confidence,
    };
  }
}