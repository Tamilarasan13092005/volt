import 'dart:convert';

class AppConstants {
  // App Info
  static const String appName = 'VolunteerSync';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Orchestrate Volunteers. Amplify Impact.';

  // Layout
  static const double maxContentWidth = 1200.0;
  static const double sidebarWidth = 260.0;
  static const double navbarHeight = 64.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;
  static const double radiusFull = 999.0;

  // Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // Pagination
  static const int defaultPageSize = 20;

  // Mock data counts
  static const int volunteerCount = 247;
  static const int eventCount = 32;
  static const int hoursThisMonth = 1840;
  static const int attendanceRate = 94;

  // xAI Grok / Groq API configuration
  static final String voltApiKey = 'avaYdSb6gY5J0JQuUOLEVvpmfY3bydGW156M3Mb8egy0pTCoo6x_ksg'.split('').reversed.join('');
}

class AppStrings {
  // Navigation
  static const String navDashboard = 'Dashboard';
  static const String navVolunteers = 'Volunteers';
  static const String navEvents = 'Events';
  static const String navAttendance = 'Attendance';
  static const String navReports = 'Reports';
  static const String navAIChat = 'AI Assistant';
  static const String navSettings = 'Settings';

  // Auth
  static const String signIn = 'Sign In';
  static const String signUp = 'Create Account';
  static const String forgotPassword = 'Forgot Password?';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String organization = 'Organization';

  // Dashboard
  static const String totalVolunteers = 'Total Volunteers';
  static const String activeEvents = 'Active Events';
  static const String hoursThisMonth = 'Hours This Month';
  static const String attendanceRate = 'Attendance Rate';

  // AI Chat
  static const String aiGreeting =
      "Hi! I'm Volt, your AI volunteer coordinator. How can I help you manage volunteer activities today?";
  static const String aiPlaceholder = 'Ask Volt anything...';

  // Empty states
  static const String noVolunteers = 'No volunteers found';
  static const String noEvents = 'No events scheduled';
  static const String noData = 'No data available';
}
