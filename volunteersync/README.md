# VolunteerSync

> **Premium AI-Powered Volunteer Management Platform**
> Built with Flutter · Dart · Provider · go_router · fl_chart · flutter_animate

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK `>=3.0.0` ([install guide](https://flutter.dev/docs/get-started/install))
- Dart SDK `>=3.0.0` (included with Flutter)
- Android Studio or VS Code with Flutter extension
- Android Emulator or physical device

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run the app
```bash
flutter run
```

### 3. Build for release
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

---

## 📱 Demo Login
Use these credentials on the login screen:
- **Email:** `alex@volunteersync.io`
- **Password:** `password123`

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── theme/          # AppTheme, AppColors
│   ├── constants/      # AppConstants, AppStrings
│   └── utils/          # AppUtils helpers
├── models/             # Volunteer, Event, Attendance, ChatMessage, User
├── services/           # (ready for API integration)
├── data/               # MockData — all dummy data
├── providers/          # AuthProvider, DashboardProvider, VolunteersProvider,
│                       # EventsProvider, ChatProvider
├── routes/             # AppRouter (go_router)
├── widgets/
│   ├── common/         # MainShell, CommonWidgets (buttons, cards, badges…)
│   ├── cards/          # StatCard, KpiCard
│   └── charts/         # VolunteerGrowthChart, AttendanceBarChart,
│                         CategoryPieChart, HoursLineChart
└── features/
    ├── auth/           # LandingScreen, LoginScreen, RegisterScreen,
    │                     ForgotPasswordScreen
    ├── dashboard/      # DashboardScreen
    ├── volunteers/     # VolunteersScreen
    ├── events/         # EventsScreen
    ├── attendance/     # AttendanceScreen
    ├── reports/        # ReportsScreen
    ├── ai_chat/        # AiChatScreen (Volt AI)
    └── settings/       # SettingsScreen
```

---

## 🎨 Design System

| Token       | Value        |
|-------------|--------------|
| Background  | `#0F172A`    |
| Surface     | `#111827`    |
| Primary     | `#6366F1`    |
| Secondary   | `#8B5CF6`    |
| Text        | `#F8FAFC`    |
| Muted       | `#94A3B8`    |

**Font:** Syne (Google Fonts fallback)  
**Style:** Futuristic AI SaaS · Glassmorphism · Dark Premium

---

## 📦 Key Packages

| Package            | Purpose                     |
|--------------------|-----------------------------|
| `provider`         | State management            |
| `go_router`        | Declarative navigation      |
| `google_fonts`     | Syne typography             |
| `fl_chart`         | Line, bar, pie charts       |
| `flutter_animate`  | Smooth entrance animations  |
| `shimmer`          | Loading skeleton screens    |
| `intl`             | Date & number formatting    |
| `uuid`             | Unique ID generation        |

---

## 🤖 AI Chat (Volt)

Volt is a mock AI assistant that understands:
- `"Generate attendance report"` → Full markdown report
- `"Suggest volunteer assignments"` → Smart recommendations
- `"Show upcoming events"` → Structured event list
- `"Analyze volunteer growth"` → Growth trends
- `"Identify at-risk volunteers"` → Flagged volunteers

To connect a real LLM, replace `_generateResponse()` in `chat_provider.dart` with an HTTP call to OpenAI, Anthropic, or any API.

---

## 🔧 Connecting a Real Backend

Replace mock data in `lib/data/mock_data.dart` and provider `load*()` methods with:

```dart
// Example: replace in volunteers_provider.dart
Future<void> loadVolunteers() async {
  _isLoading = true;
  notifyListeners();
  
  final response = await http.get(Uri.parse('https://yourapi.com/volunteers'));
  final List data = jsonDecode(response.body);
  _volunteers = data.map((j) => Volunteer.fromJson(j)).toList();
  
  _isLoading = false;
  notifyListeners();
}
```

---

## 📸 Screens

1. **Landing** — Hero with features, CTAs, stats
2. **Login** — Email/password with demo hint
3. **Register** — Full onboarding flow
4. **Forgot Password** — Email reset + success state
5. **Dashboard** — Stats, charts, activity feed, AI insight
6. **Volunteers** — Search, filter, detail sheets
7. **Events** — Cards with fill-rate bars, detail sheets
8. **Attendance** — Check-in, records, event breakdown
9. **Reports** — Full analytics with 4 chart types + top table
10. **AI Chat** — Volt assistant with markdown, typing indicator, sidebar
11. **Settings** — Profile, notifications, security, preferences

---

## 🏗 Architecture

- **Feature-first** folder structure
- **Provider** for reactive state
- **go_router** with ShellRoute for persistent navigation
- **Clean separation** of models / data / providers / UI
- **Responsive** — sidebar on tablet/desktop, bottom nav on mobile

---

## 📄 License

MIT — Free to use for commercial and personal projects.

---

*Built with ❤️ by VolunteerSync Team*
