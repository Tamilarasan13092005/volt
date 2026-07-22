import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/chat_message.dart';


class ChatProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  static const String _storageKey = 'volt_chat_sessions';

  List<ChatSession> _sessions = [];
  ChatSession? _activeSession;
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _sidebarOpen = false;

  List<ChatSession> get sessions => _sessions;
  ChatSession? get activeSession => _activeSession;
  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get sidebarOpen => _sidebarOpen;
  List<String> get suggestions => const [
    '📋 List of volunteers',
    '📅 List of events available',
    '🔔 Upcoming events',
  ];

  Future<void> init() async {
    if (_sessions.isEmpty) {
      await _loadSessions();
      if (_sessions.isEmpty) {
        _startNewSession();
      } else {
        notifyListeners();
      }
    }
  }

  void toggleSidebar() {
    _sidebarOpen = !_sidebarOpen;
    notifyListeners();
  }

  void _startNewSession() {
    final session = ChatSession(
      id: _uuid.v4(),
      title: 'New Conversation',
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
      messages: [],
      messageCount: 0,
    );
    _activeSession = session;
    _messages = [];
    // Add greeting
    final greeting = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: 'Hi! I\'m **Volt**, your AI volunteer coordinator. How can I help you manage volunteer activities today?',
      timestamp: DateTime.now(),
    );
    _messages.add(greeting);
    
    // Save greeting to active session and add active session to sessions list
    _activeSession = session.copyWith(
      messages: [greeting],
      messageCount: 1,
    );
    _sessions.add(_activeSession!);
    _saveSessions();
    notifyListeners();
  }

  void newSession() => _startNewSession();

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_storageKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(dataStr);
        _sessions = jsonList
            .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
            .toList();
        if (_sessions.isNotEmpty) {
          _activeSession = _sessions.last;
          _messages = List.from(_activeSession!.messages);
        }
      }
    } catch (e) {
      debugPrint("Error loading chat sessions: $e");
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = jsonEncode(_sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKey, dataStr);
    } catch (e) {
      debugPrint("Error saving chat sessions: $e");
    }
  }

  void _addMessageToSession(ChatMessage msg) {
    if (_activeSession == null) return;
    
    final updatedMessages = [..._messages];
    
    final updatedSession = _activeSession!.copyWith(
      messages: updatedMessages,
      messageCount: updatedMessages.length,
      lastMessageAt: DateTime.now(),
      title: (_activeSession!.title == 'New Conversation' && msg.role == MessageRole.user)
          ? (msg.content.length > 25 ? '${msg.content.substring(0, 25)}...' : msg.content)
          : _activeSession!.title,
    );
    
    _activeSession = updatedSession;
    
    final index = _sessions.indexWhere((s) => s.id == updatedSession.id);
    if (index != -1) {
      _sessions[index] = updatedSession;
    } else {
      _sessions.add(updatedSession);
    }
    _saveSessions();
  }

  void selectSession(String id) {
    final session = _sessions.firstWhere((s) => s.id == id,
        orElse: () => _sessions.first);
    _activeSession = session;
    _messages = List.from(session.messages);
    notifyListeners();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (_activeSession?.id == id) {
      if (_sessions.isNotEmpty) {
        _activeSession = _sessions.last;
        _messages = List.from(_activeSession!.messages);
      } else {
        _startNewSession();
      }
    }
    _saveSessions();
    notifyListeners();
  }

  Future<String> _getDatabaseContext() async {
    String contextStr = "";
    try {
      final supabase = Supabase.instance.client;
      
      // Fetch active volunteers (limit to 25)
      final volRes = await supabase.from('volunteers')
          .select('full_name, email, phone, availability, status, total_hours, location, bio')
          .limit(25);
      
      final volList = volRes as List;
      String volStr = volList.isEmpty 
          ? "No volunteers found in the database."
          : volList.map((v) {
              return "- Name: ${v['full_name']}\n  Email: ${v['email']}\n  Phone: ${v['phone'] ?? 'N/A'}\n  Role/Availability: ${v['availability']}\n  Status: ${v['status']}\n  Total Hours: ${v['total_hours']} hours\n  Location: ${v['location'] ?? 'N/A'}\n  Bio: ${v['bio'] ?? 'N/A'}";
            }).join("\n\n");

      // Fetch events (limit to 15)
      final eventRes = await supabase.from('events')
          .select('title, description, location, start_date, end_date, status, category, organizer, target_volunteers, registered_volunteers')
          .limit(15);
      
      final eventList = eventRes as List;
      String eventStr = eventList.isEmpty
          ? "No events scheduled."
          : eventList.map((e) {
              return "- Title: ${e['title']}\n  Description: ${e['description'] ?? 'N/A'}\n  Location: ${e['location']}\n  Date: ${e['start_date']} to ${e['end_date']}\n  Status: ${e['status']}\n  Category: ${e['category']}\n  Organizer: ${e['organizer']}\n  Capacity: ${e['registered_volunteers']}/${e['target_volunteers']} volunteers";
            }).join("\n\n");

      // Fetch profiles/organizers
      final profileRes = await supabase.from('profiles')
          .select('full_name, email, role')
          .limit(15);
          
      final profileList = profileRes as List;
      String profileStr = profileList.isEmpty
          ? "No user/organizer profiles found."
          : profileList.map((p) {
              return "- Name: ${p['full_name']}\n  Email: ${p['email']}\n  Role: ${p['role']}";
            }).join("\n\n");

      contextStr = """
Here is the current real-time data from the database:

--- VOLUNTEERS IN DATABASE ---
$volStr

--- EVENTS IN DATABASE ---
$eventStr

--- USER/ORGANIZER PROFILES ---
$profileStr
""";
    } catch (e) {
      debugPrint("Error fetching database context for Volt: $e");
    }
    return contextStr;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.user,
      content: text.trim(),
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _addMessageToSession(userMsg);
    _isTyping = true;
    notifyListeners();

    String reply;

    if (AppConstants.voltApiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 1000));
      reply = 'Volt API Key is not configured. Please paste your API Key in `AppConstants.voltApiKey` to chat with Volt.';
    } else {
      try {
        final isGroq = AppConstants.voltApiKey.startsWith('gsk_');
        final url = Uri.parse(isGroq
            ? 'https://api.groq.com/openai/v1/chat/completions'
            : 'https://api.x.ai/v1/chat/completions');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.voltApiKey}',
        };

        // Fetch real-time database context
        final databaseContext = await _getDatabaseContext();

        // Convert message history to format expected by API
        final historyList = _messages.map((m) {
          String roleStr = 'user';
          if (m.role == MessageRole.assistant) {
            roleStr = 'assistant';
          } else if (m.role == MessageRole.system) {
            roleStr = 'system';
          }
          return {
            'role': roleStr,
            'content': m.content,
          };
        }).toList();

        final body = jsonEncode({
          'model': isGroq ? 'llama-3.1-8b-instant' : 'grok-2-1212',
          'messages': [
            {
              'role': 'system',
              'content': 'You are Volt, a friendly, highly interactive, and conversational AI volunteer coordinator. Engage the user in a natural, active chat. You have access to the real-time database context below containing the list of registered volunteers, events, and organizers.\n\nCRITICAL RULE: You MUST ONLY refer to and use the volunteers and events that are present in the provided database context. DO NOT hallucinate, invent, or output any dummy volunteer names or events (like "Alex Chen", "Emily Patel", "Benjamin Lee", "Sophia Rodriguez", "Michael Kim", etc.) that are not in the context list. If a volunteer or event is not listed in the database context, you must state that they do not exist in the database. If the database context is empty, state that there are no volunteers or events registered.\n\nHere is the real-time database context:\n$databaseContext'
            },
            ...historyList,
          ],
          'temperature': 0.7,
        });

        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          reply = data['choices'][0]['message']['content'] ?? 'No response content.';
        } else {
          final apiName = isGroq ? 'Groq' : 'Volt';
          reply = 'Error from $apiName API (Status ${response.statusCode}): ${response.body}';
        }
      } catch (e) {
        final apiName = AppConstants.voltApiKey.startsWith('gsk_') ? 'Groq' : 'Volt';
        reply = 'Failed to connect to $apiName API: $e';
      }
    }

    final aiMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: reply,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
    _addMessageToSession(aiMsg);
    _isTyping = false;
    notifyListeners();
  }
}
