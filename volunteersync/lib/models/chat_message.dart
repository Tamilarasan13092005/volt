enum MessageRole { user, assistant, system }

enum MessageType { text, suggestion, report, loading }

class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isStreaming;
  final List<String>? suggestions;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isStreaming = false,
    this.suggestions,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    bool? isStreaming,
    List<String>? suggestions,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isStreaming: isStreaming ?? this.isStreaming,
      suggestions: suggestions ?? this.suggestions,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;
  final int messageCount;

  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
    required this.messageCount,
  });

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessage>? messages,
    int? messageCount,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}
