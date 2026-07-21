class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // admin, coordinator, volunteer
  final String organization;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isVerified;
  final Map<String, dynamic>? preferences;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.organization,
    this.avatarUrl,
    required this.createdAt,
    this.isVerified = false,
    this.preferences,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      organization: json['organization'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'organization': organization,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
        'isVerified': isVerified,
        'preferences': preferences,
      };

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? organization,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isVerified,
    Map<String, dynamic>? preferences,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      preferences: preferences ?? this.preferences,
    );
  }
}

// Dashboard stats model
class DashboardStats {
  final int totalVolunteers;
  final int activeVolunteers;
  final int totalEvents;
  final int upcomingEvents;
  final int hoursThisMonth;
  final int hoursLastMonth;
  final double attendanceRate;
  final double attendanceRateLastMonth;
  final int newVolunteersThisMonth;
  final double volunteerGrowthPercent;

  const DashboardStats({
    required this.totalVolunteers,
    required this.activeVolunteers,
    required this.totalEvents,
    required this.upcomingEvents,
    required this.hoursThisMonth,
    this.hoursLastMonth = 0,
    required this.attendanceRate,
    this.attendanceRateLastMonth = 0,
    required this.newVolunteersThisMonth,
    required this.volunteerGrowthPercent,
  });

  /// Month-over-month hours change as a formatted string e.g. "+8.2%"
  String get hoursChangePercent {
    if (hoursLastMonth == 0) return '--';
    final delta = ((hoursThisMonth - hoursLastMonth) / hoursLastMonth) * 100;
    return '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%';
  }

  /// Month-over-month attendance rate change as a formatted string e.g. "+1.3%"
  String get attendanceChangePercent {
    if (attendanceRateLastMonth == 0) return '--';
    final delta = attendanceRate - attendanceRateLastMonth;
    return '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%';
  }
}
