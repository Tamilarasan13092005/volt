import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../data/mock_data.dart';

class ChatProvider extends ChangeNotifier {
  final _uuid = const Uuid();

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
  List<String> get suggestions => MockData.aiSuggestions;

  void init() {
    _sessions = List.from(MockData.chatSessions);
    _startNewSession();
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
      content: MockData.aiSuggestions.isNotEmpty
          ? 'Hi! I\'m **Volt**, your AI volunteer coordinator. I can help you manage volunteers, analyze attendance, and optimize your events.\n\nWhat would you like to do today?'
          : '',
      timestamp: DateTime.now(),
    );
    _messages.add(greeting);
    notifyListeners();
  }

  void newSession() => _startNewSession();

  void selectSession(String id) {
    final session = _sessions.firstWhere((s) => s.id == id,
        orElse: () => _sessions.first);
    _activeSession = session;
    _messages = [];
    final greeting = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: 'Continuing our conversation about **${session.title}**. How can I help?',
      timestamp: DateTime.now(),
    );
    _messages.add(greeting);
    notifyListeners();
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
    _isTyping = true;
    notifyListeners();

    // Simulate AI thinking
    await Future.delayed(const Duration(milliseconds: 1200));

    final aiMsg = ChatMessage(
      id: _uuid.v4(),
      role: MessageRole.assistant,
      content: _generateResponse(text),
      timestamp: DateTime.now(),
    );
    _messages.add(aiMsg);
    _isTyping = false;
    notifyListeners();
  }

  String _generateResponse(String input) {
    final q = input.toLowerCase();

    if (q.contains('attendance') && q.contains('report')) {
      return '''## 📊 Attendance Report — March 2024

Here's your attendance summary:

| Metric | Value |
|--------|-------|
| Total Events | 6 |
| Avg Attendance Rate | **94.2%** |
| Total Hours Logged | 1,840 hrs |
| Top Performer | Maya Chen (98.5%) |

**Insights:**
- Coastal Cleanup had the highest turnout (82/87 registered)
- Saturday events consistently outperform weekday ones
- 3 volunteers with <85% rate — consider outreach

Would you like me to export this as a PDF or drill into a specific event?''';
    }

    if (q.contains('volunteer') && (q.contains('assign') || q.contains('suggest'))) {
      return '''## 👥 Volunteer Assignment Recommendations

For the **Annual Community Food Drive** (5 days away), I suggest:

1. **Maya Chen** — Team Lead, 98.5% attendance, has prior food drive experience
2. **James Okafor** — Strong logistics skills, available on event day
3. **Nina Kowalski** — Marketing + coordination; perfect for donor relations
4. **Sofia Reyes** — Bilingual, great for community outreach tables

**Understaffed areas (need 8 more volunteers):**
- Box sorting station (3 needed)
- Distribution line (5 needed)

I can send automated invitations to matched volunteers. Shall I proceed?''';
    }

    if (q.contains('upcoming') || q.contains('events')) {
      return '''## 📅 Upcoming Events

Here are your next **3 events**:

**1. Annual Community Food Drive**
📍 SF Civic Center · In 5 days
👥 42/50 volunteers registered · 84% filled

**2. Youth STEM Workshop Series**
📍 Oakland Tech Hub · In 12 days
👥 18/20 volunteers registered · 90% filled

**3. Emergency Housing Build**
📍 East Palo Alto · In 20 days
👥 22/30 volunteers registered · 73% filled ⚠️

The Housing Build needs urgent attention — 8 more volunteers required. Would you like me to identify and notify eligible volunteers?''';
    }

    if (q.contains('growth') || q.contains('analytic')) {
      return '''## 📈 Volunteer Growth Analytics

**9-Month Trend (Jul 2023 – Mar 2024):**
- Started: 180 volunteers
- Current: 247 volunteers
- Growth: **+37.2%** 🚀

**Key drivers:**
- Q4 2023 social campaign (+25 volunteers in Oct)
- University partnership launched Jan 2024
- Referral program added 18 volunteers in Feb

**Churn rate:** 4.1% (industry avg: 8%)
You're performing exceptionally well on retention.

**Forecast:** At current pace, you'll reach **280 active volunteers** by June 2024.''';
    }

    if (q.contains('at-risk') || q.contains('risk')) {
      return '''## ⚠️ At-Risk Volunteer Identification

I've flagged **3 volunteers** who may need engagement outreach:

1. **Ravi Patel** — Attendance dropped from 92% → 85% over 2 months. Last check-in: 3 weeks ago.
2. **Liam Park** — Missed last 2 events without notice. Skills underutilized.
3. **Kwame Asante** — Pending status for 23 days. No event assigned yet.

**Recommended actions:**
- Send personalized check-in message
- Assign Kwame to Housing Build (matches skills)
- Schedule 1:1 with Ravi for feedback

Want me to draft outreach messages for each?''';
    }

    if (q.contains('hello') || q.contains('hi') || q.contains('hey')) {
      return "Hello! 👋 I'm Volt, ready to help you coordinate volunteers and optimize your programs. Try asking me to generate a report, suggest assignments, or analyze your event data!";
    }

    return '''I understand you're asking about **"$input"**.

As your AI coordinator, I can help with:

- 📊 **Reports** — Attendance, hours, and performance analytics
- 👥 **Volunteers** — Assignments, at-risk identification, outreach
- 📅 **Events** — Planning, optimization, volunteer matching
- 📈 **Analytics** — Growth trends, forecasting, insights

Could you rephrase or be more specific? For example:
*"Generate attendance report for March"* or *"Who should I assign to the food drive?"*''';
  }
}
