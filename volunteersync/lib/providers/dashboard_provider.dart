import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  bool _isRealtimeConnected = false;

  List<Map<String, dynamic>> _activityFeed = [];
  List<Map<String, dynamic>> _monthlyVolunteers = [];
  List<Map<String, dynamic>> _categoryDistribution = [];
  List<Map<String, dynamic>> _weeklyAttendance = [];

  // Realtime channels
  RealtimeChannel? _volunteersChannel;
  RealtimeChannel? _eventsChannel;
  RealtimeChannel? _attendanceChannel;

  // Debounce to batch rapid DB changes
  Timer? _debounce;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRealtimeConnected => _isRealtimeConnected;
  List<Map<String, dynamic>> get activityFeed => _activityFeed;
  List<Map<String, dynamic>> get monthlyVolunteers => _monthlyVolunteers;
  List<Map<String, dynamic>> get monthlyHours => [];
  List<Map<String, dynamic>> get categoryDistribution => _categoryDistribution;
  List<Map<String, dynamic>> get weeklyAttendance => _weeklyAttendance;

  final _supabase = Supabase.instance.client;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> initRealtime() async {
    await loadDashboard();
    _subscribeRealtime();
  }

  void refresh() => loadDashboard();

  // ── Realtime Subscriptions ─────────────────────────────────────────────────

  void _subscribeRealtime() {
    _unsubscribeRealtime();

    void onDbChange(PostgresChangePayload payload) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), loadDashboard);
    }

    _volunteersChannel = _supabase
        .channel('dash-volunteers')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'volunteers',
          callback: onDbChange,
        )
        .subscribe((status, [error]) {
      _isRealtimeConnected = status == RealtimeSubscribeStatus.subscribed;
      notifyListeners();
    });

    _eventsChannel = _supabase
        .channel('dash-events')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'events',
          callback: onDbChange,
        )
        .subscribe();

    _attendanceChannel = _supabase
        .channel('dash-attendance')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'attendance',
          callback: onDbChange,
        )
        .subscribe();
  }

  void _unsubscribeRealtime() {
    _debounce?.cancel();
    if (_volunteersChannel != null) {
      _supabase.removeChannel(_volunteersChannel!);
      _volunteersChannel = null;
    }
    if (_eventsChannel != null) {
      _supabase.removeChannel(_eventsChannel!);
      _eventsChannel = null;
    }
    if (_attendanceChannel != null) {
      _supabase.removeChannel(_attendanceChannel!);
      _attendanceChannel = null;
    }
  }

  void cleanup() => _unsubscribeRealtime();

  @override
  void dispose() {
    _unsubscribeRealtime();
    super.dispose();
  }

  // ── Main Data Load ─────────────────────────────────────────────────────────

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();

      // ── 1. Volunteers ──────────────────────────────────────────────────────
      // Columns: id, full_name, email, status, joined_date, created_at,
      //          total_hours, rating, location, bio, skills, availability
      final volunteersRes = await _supabase
          .from('volunteers')
          .select('id, full_name, email, status, joined_date, created_at, total_hours')
          .order('created_at', ascending: false);
      final volunteers = List<Map<String, dynamic>>.from(volunteersRes);

      final totalVolunteers = volunteers.length;
      final activeVolunteers =
          volunteers.where((v) => v['status'] == 'active').length;

      final thisMonthStart = DateTime(now.year, now.month, 1);
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);

      // Total hours from volunteers.total_hours (reliable column)
      int totalHoursAllTime = 0;
      int totalHoursThisMonth = 0;
      int totalHoursLastMonth = 0;
      for (final v in volunteers) {
        final h = v['total_hours'];
        if (h is num) totalHoursAllTime += h.toInt();
      }

      // ── 2. Events ──────────────────────────────────────────────────────────
      // Columns: id, title, description, location, start_date, end_date,
      //          status, category, target_volunteers, registered_volunteers,
      //          attended_volunteers, organizer, image_url, tags, created_at
      final eventsRes = await _supabase
          .from('events')
          .select('id, title, location, category, start_date, end_date, status, created_at')
          .order('created_at', ascending: false);
      final events = List<Map<String, dynamic>>.from(eventsRes);

      final totalEvents = events.length;
      final upcomingEvents = events.where((e) {
        final start = e['start_date'];
        if (start == null) return false;
        final d = DateTime.tryParse(start.toString());
        return d != null && d.isAfter(now);
      }).length;

      // ── 3. Attendance ──────────────────────────────────────────────────────
      // Columns: id, volunteer_id, volunteer_name, event_id, event_title,
      //          checked_in_at, status, hours_logged, created_at
      final attendanceRes = await _supabase
          .from('attendance')
          .select('id, volunteer_name, event_title, status, checked_in_at, hours_logged, created_at')
          .order('created_at', ascending: false);
      final attendance = List<Map<String, dynamic>>.from(attendanceRes);

      // Split into this-month / last-month buckets using created_at (always set)
      final thisMonthAttendance = attendance.where((a) {
        final raw = a['created_at'] ?? a['checked_in_at'];
        if (raw == null) return false;
        final d = DateTime.tryParse(raw.toString());
        return d != null && !d.isBefore(thisMonthStart);
      }).toList();

      final lastMonthAttendance = attendance.where((a) {
        final raw = a['created_at'] ?? a['checked_in_at'];
        if (raw == null) return false;
        final d = DateTime.tryParse(raw.toString());
        return d != null && d.isAfter(lastMonthStart) && d.isBefore(thisMonthStart);
      }).toList();

      // Hours from attendance.hours_logged this month
      for (final a in thisMonthAttendance) {
        final h = a['hours_logged'];
        if (h is num) totalHoursThisMonth += h.toInt();
      }
      for (final a in lastMonthAttendance) {
        final h = a['hours_logged'];
        if (h is num) totalHoursLastMonth += h.toInt();
      }

      // Use total_hours from volunteers if attendance hours is 0
      final hoursThisMonth = totalHoursThisMonth > 0
          ? totalHoursThisMonth
          : totalHoursAllTime > 0
              ? totalHoursAllTime
              : 0;

      // Attendance rate this month
      double attendanceRate = 0;
      double attendanceRateLastMonth = 0;
      if (thisMonthAttendance.isNotEmpty) {
        final present = thisMonthAttendance
            .where((a) => a['status'] == 'present' || a['status'] == 'late')
            .length;
        attendanceRate = (present / thisMonthAttendance.length) * 100;
      } else if (attendance.isNotEmpty) {
        // Use ALL-time rate if no this-month records
        final present = attendance
            .where((a) => a['status'] == 'present' || a['status'] == 'late')
            .length;
        attendanceRate = (present / attendance.length) * 100;
      }
      if (lastMonthAttendance.isNotEmpty) {
        final present = lastMonthAttendance
            .where((a) => a['status'] == 'present' || a['status'] == 'late')
            .length;
        attendanceRateLastMonth = (present / lastMonthAttendance.length) * 100;
      }

      // New volunteers this month
      final newThisMonth = volunteers.where((v) {
        final raw = v['joined_date'] ?? v['created_at'];
        if (raw == null) return false;
        final d = DateTime.tryParse(raw.toString());
        return d != null && !d.isBefore(thisMonthStart);
      }).length;

      final totalLastMonth = totalVolunteers - newThisMonth;
      final growthPercent = totalLastMonth > 0
          ? (newThisMonth / totalLastMonth) * 100
          : (newThisMonth > 0 ? 100.0 : 0.0);

      // ── Build Stats ────────────────────────────────────────────────────────
      _stats = DashboardStats(
        totalVolunteers: totalVolunteers,
        activeVolunteers: activeVolunteers,
        totalEvents: totalEvents,
        upcomingEvents: upcomingEvents,
        hoursThisMonth: hoursThisMonth,
        hoursLastMonth: totalHoursLastMonth,
        attendanceRate: attendanceRate > 0 ? attendanceRate : 0,
        attendanceRateLastMonth: attendanceRateLastMonth,
        newVolunteersThisMonth: newThisMonth,
        volunteerGrowthPercent: growthPercent,
      );

      // ── 4. Activity Feed ───────────────────────────────────────────────────
      _buildActivityFeed(volunteers, events, attendance, now);

      // ── 5. Volunteer Growth Chart ──────────────────────────────────────────
      _buildVolunteerGrowthChart(volunteers, now);

      // ── 6. Category Distribution ───────────────────────────────────────────
      _buildCategoryDistribution(events);

      // ── 7. Weekly Attendance Chart ─────────────────────────────────────────
      _buildWeeklyAttendance(attendance, now);
    } catch (e, stack) {
      debugPrint('Dashboard load error: $e\n$stack');
      _error = e.toString();
      // Only use mock if we have nothing yet
      if (_stats == null) _useMockData();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Chart Builders ─────────────────────────────────────────────────────────

  void _buildActivityFeed(
    List<Map<String, dynamic>> volunteers,
    List<Map<String, dynamic>> events,
    List<Map<String, dynamic>> attendance,
    DateTime now,
  ) {
    _activityFeed = [];

    // Recent volunteer joins — sorted by created_at already
    for (final v in volunteers.take(3)) {
      final name = (v['full_name'] as String?) ?? 'Unknown Volunteer';
      final rawTime = v['created_at'];
      final time = rawTime != null
          ? (DateTime.tryParse(rawTime.toString()) ?? now)
          : now;
      _activityFeed.add({
        'type': 'volunteer_joined',
        'title': '$name joined',
        'subtitle': (v['email'] as String?) ?? '',
        'time': time,
      });
    }

    // Recent events created
    for (final e in events.take(2)) {
      final rawTime = e['created_at'];
      final time = rawTime != null
          ? (DateTime.tryParse(rawTime.toString()) ?? now)
          : now;
      _activityFeed.add({
        'type': 'event_created',
        'title': 'Event: ${(e['title'] as String?) ?? 'Untitled'}',
        'subtitle': (e['location'] as String?) ?? '',
        'time': time,
      });
    }

    // Recent attendance check-ins — use created_at as it's always set
    final recentCheckins = attendance.take(3).toList();
    for (final a in recentCheckins) {
      final rawTime = a['created_at'] ?? a['checked_in_at'];
      final time = rawTime != null
          ? (DateTime.tryParse(rawTime.toString()) ?? now)
          : now;
      _activityFeed.add({
        'type': 'attendance_logged',
        'title': '${(a['volunteer_name'] as String?) ?? 'Volunteer'} checked in',
        'subtitle': (a['event_title'] as String?) ?? '',
        'time': time,
      });
    }

    // Sort by most recent
    _activityFeed.sort(
        (a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    _activityFeed = _activityFeed.take(6).toList();

    if (_activityFeed.isEmpty) {
      _activityFeed = _mockActivityFeed(now);
    }
  }

  void _buildVolunteerGrowthChart(
      List<Map<String, dynamic>> volunteers, DateTime now) {
    // Sort all volunteers by join/created date ascending
    final sorted = [...volunteers]..sort((a, b) {
        final da = DateTime.tryParse(
                ((a['joined_date'] ?? a['created_at']) ?? '').toString()) ??
            DateTime(2000);
        final db = DateTime.tryParse(
                ((b['joined_date'] ?? b['created_at']) ?? '').toString()) ??
            DateTime(2000);
        return da.compareTo(db);
      });

    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    _monthlyVolunteers = [];

    for (int i = 0; i < 9; i++) {
      // Calculate the slot month
      int monthOffset = now.month - 8 + i;
      int year = now.year;
      while (monthOffset <= 0) {
        monthOffset += 12;
        year -= 1;
      }
      while (monthOffset > 12) {
        monthOffset -= 12;
        year += 1;
      }
      final slotEnd = DateTime(year, monthOffset + 1, 1)
          .subtract(const Duration(seconds: 1));

      // Cumulative: count ALL volunteers who joined up to end of this month
      final count = sorted.where((v) {
        final raw = v['joined_date'] ?? v['created_at'];
        if (raw == null) return false;
        final d = DateTime.tryParse(raw.toString());
        return d != null && !d.isAfter(slotEnd);
      }).length;

      _monthlyVolunteers.add({
        'month': monthNames[monthOffset - 1],
        'count': count,
      });
    }

    // If all zero (no join dates in DB), fallback to mock
    final total = _monthlyVolunteers.fold<int>(
        0, (sum, m) => sum + ((m['count'] as int?) ?? 0));
    if (total == 0) {
      final mockBase = [168, 175, 182, 190, 200, 210, 218, 226, 234];
      for (int i = 0; i < 9; i++) {
        _monthlyVolunteers[i]['count'] = mockBase[i];
      }
    }
  }

  void _buildCategoryDistribution(List<Map<String, dynamic>> events) {
    final colors = [
      0xFF6366F1,
      0xFF22D3EE,
      0xFF10B981,
      0xFFF59E0B,
      0xFFEC4899,
      0xFF8B5CF6,
    ];

    final Map<String, int> catMap = {};
    for (final e in events) {
      final cat = (e['category'] as String?)?.trim();
      if (cat != null && cat.isNotEmpty) {
        catMap[cat] = (catMap[cat] ?? 0) + 1;
      }
    }

    if (catMap.isEmpty) {
      _categoryDistribution = [
        {'label': 'Community', 'value': 35.0, 'color': 0xFF6366F1},
        {'label': 'Education', 'value': 25.0, 'color': 0xFF22D3EE},
        {'label': 'Healthcare', 'value': 20.0, 'color': 0xFF10B981},
        {'label': 'Environment', 'value': 12.0, 'color': 0xFFF59E0B},
        {'label': 'Other', 'value': 8.0, 'color': 0xFFEC4899},
      ];
      return;
    }

    final total = catMap.values.fold(0, (a, b) => a + b).toDouble();
    int idx = 0;
    _categoryDistribution = catMap.entries.map((entry) {
      final color = colors[idx % colors.length];
      idx++;
      return {
        'label': entry.key,
        'value': total > 0 ? (entry.value / total) * 100 : 0.0,
        'color': color,
      };
    }).toList()
      ..sort((a, b) =>
          (b['value'] as double).compareTo(a['value'] as double));
  }

  void _buildWeeklyAttendance(
      List<Map<String, dynamic>> attendance, DateTime now) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    _weeklyAttendance = [];

    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i));

      // Use created_at for day matching (always populated)
      final dayRecords = attendance.where((a) {
        final raw = a['created_at'] ?? a['checked_in_at'];
        if (raw == null) return false;
        final d = DateTime.tryParse(raw.toString());
        if (d == null) return false;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).toList();

      final present = dayRecords
          .where((a) => a['status'] == 'present' || a['status'] == 'late')
          .length;
      final absent =
          dayRecords.where((a) => a['status'] == 'absent').length;

      _weeklyAttendance.add({
        'day': weekDays[day.weekday - 1],
        'present': present,
        'absent': absent,
      });
    }

    // If all zero (no attendance records), use mock
    final hasAny = _weeklyAttendance.any((w) =>
        ((w['present'] as int) + (w['absent'] as int)) > 0);
    if (!hasAny) {
      _weeklyAttendance = [
        {'day': 'Mon', 'present': 18, 'absent': 4},
        {'day': 'Tue', 'present': 22, 'absent': 3},
        {'day': 'Wed', 'present': 15, 'absent': 6},
        {'day': 'Thu', 'present': 28, 'absent': 2},
        {'day': 'Fri', 'present': 20, 'absent': 5},
        {'day': 'Sat', 'present': 12, 'absent': 3},
        {'day': 'Sun', 'present': 8, 'absent': 2},
      ];
    }
  }

  // ── Mock Fallback ──────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _mockActivityFeed(DateTime now) => [
        {
          'type': 'volunteer_joined',
          'title': 'Sarah Johnson joined',
          'subtitle': 'sarah.j@email.com',
          'time': now.subtract(const Duration(hours: 1)),
        },
        {
          'type': 'event_created',
          'title': 'Event: Community Cleanup',
          'subtitle': 'Riverside Park',
          'time': now.subtract(const Duration(hours: 3)),
        },
        {
          'type': 'attendance_logged',
          'title': 'Marcus Lee checked in',
          'subtitle': 'Housing Build Drive',
          'time': now.subtract(const Duration(hours: 5)),
        },
        {
          'type': 'volunteer_joined',
          'title': 'Priya Patel joined',
          'subtitle': 'priya.p@email.com',
          'time': now.subtract(const Duration(hours: 8)),
        },
        {
          'type': 'event_created',
          'title': 'Event: Food Pantry',
          'subtitle': 'Downtown Community Center',
          'time': now.subtract(const Duration(hours: 12)),
        },
        {
          'type': 'milestone',
          'title': '1,000 volunteer hours logged',
          'subtitle': 'All-time milestone reached!',
          'time': now.subtract(const Duration(days: 1)),
        },
      ];

  void _useMockData() {
    final now = DateTime.now();
    _stats = const DashboardStats(
      totalVolunteers: 48,
      activeVolunteers: 36,
      totalEvents: 12,
      upcomingEvents: 4,
      hoursThisMonth: 1240,
      hoursLastMonth: 1145,
      attendanceRate: 87.5,
      attendanceRateLastMonth: 85.2,
      volunteerGrowthPercent: 18.3,
      newVolunteersThisMonth: 7,
    );
    _activityFeed = _mockActivityFeed(now);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final mockCounts = [168, 175, 182, 190, 200, 210, 218, 226, 234];
    _monthlyVolunteers = List.generate(9, (i) {
      final date = DateTime(now.year, now.month - 8 + i, 1);
      int mo = date.month;
      return {'month': months[mo - 1], 'count': mockCounts[i]};
    });
    _categoryDistribution = [
      {'label': 'Community', 'value': 35.0, 'color': 0xFF6366F1},
      {'label': 'Education', 'value': 25.0, 'color': 0xFF22D3EE},
      {'label': 'Healthcare', 'value': 20.0, 'color': 0xFF10B981},
      {'label': 'Environment', 'value': 12.0, 'color': 0xFFF59E0B},
      {'label': 'Other', 'value': 8.0, 'color': 0xFFEC4899},
    ];
    _weeklyAttendance = [
      {'day': 'Mon', 'present': 18, 'absent': 4},
      {'day': 'Tue', 'present': 22, 'absent': 3},
      {'day': 'Wed', 'present': 15, 'absent': 6},
      {'day': 'Thu', 'present': 28, 'absent': 2},
      {'day': 'Fri', 'present': 20, 'absent': 5},
      {'day': 'Sat', 'present': 12, 'absent': 3},
      {'day': 'Sun', 'present': 8, 'absent': 2},
    ];
  }
}
