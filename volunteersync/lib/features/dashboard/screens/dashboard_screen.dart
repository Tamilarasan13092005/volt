import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/cards/stat_card.dart';
import '../../../widgets/charts/chart_widgets.dart';
import '../../../widgets/common/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardProvider _dashProvider;

  @override
  void initState() {
    super.initState();
    _dashProvider = context.read<DashboardProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dashProvider.initRealtime();
    });
  }

  @override
  void dispose() {
    // Cancel realtime channels without destroying the shared provider
    _dashProvider.cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final user = context.read<AuthProvider>().user;
    final isMobile = AppUtils.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: dash.isLoading
          ? _buildShimmer()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good morning, ${user?.name.split(' ').first ?? 'there'} 👋',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Dashboard Overview',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(width: 10),
                                      _LiveIndicator(
                                          connected: dash.isRealtimeConnected),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // AI chat shortcut
                            GestureDetector(
                              onTap: () => context.go(AppRouter.aiChat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text('Ask Volt',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 16),

                        // Error banner
                        if (dash.error != null)
                          _ErrorBanner(message: dash.error!)
                              .animate()
                              .fadeIn()
                              .slideY(begin: -0.1),

                        if (dash.error != null) const SizedBox(height: 16),

                        // Stat cards
                        if (dash.stats != null) ...[
                          isMobile
                              ? _MobileStatGrid(stats: dash.stats)
                              : _DesktopStatRow(stats: dash.stats),
                          const SizedBox(height: 28),
                        ],

                        // AI Insights Banner
                        _AIInsightsBanner()
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.1),

                        const SizedBox(height: 28),

                        // Charts row
                        isMobile
                            ? _MobileChartsColumn(dash: dash)
                            : _DesktopChartsRow(dash: dash),

                        const SizedBox(height: 28),

                        // Bottom section
                        isMobile
                            ? _MobileBottomSection(dash: dash)
                            : _DesktopBottomSection(dash: dash),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 200, height: 28),
          const SizedBox(height: 8),
          const ShimmerBox(width: 140, height: 18),
          const SizedBox(height: 28),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(4,
                (_) => const ShimmerBox(width: double.infinity, height: 120)),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: double.infinity, height: 180),
        ],
      ),
    );
  }
}

class _MobileStatGrid extends StatelessWidget {
  final dynamic stats;
  const _MobileStatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        StatCard(
          label: AppStrings.totalVolunteers,
          value: stats.totalVolunteers.toString(),
          change: '+${stats.volunteerGrowthPercent.toStringAsFixed(1)}%',
          icon: Icons.people_rounded,
          gradient: AppColors.primaryGradient,
          animationDelay: 200,
        ),
        StatCard(
          label: AppStrings.activeEvents,
          value: stats.upcomingEvents.toString(),
          change: '${stats.totalEvents} total',
          icon: Icons.event_rounded,
          gradient: AppColors.cyanGradient,
          animationDelay: 300,
        ),
        StatCard(
          label: AppStrings.hoursThisMonth,
          value: AppUtils.formatNumber(stats.hoursThisMonth),
          change: stats.hoursChangePercent,
          icon: Icons.schedule_rounded,
          gradient: AppColors.emeraldGradient,
          animationDelay: 400,
        ),
        StatCard(
          label: AppStrings.attendanceRate,
          value: '${stats.attendanceRate.toStringAsFixed(1)}%',
          change: stats.attendanceChangePercent,
          icon: Icons.fact_check_rounded,
          gradient: AppColors.amberGradient,
          animationDelay: 500,
        ),
      ],
    );
  }
}

class _DesktopStatRow extends StatelessWidget {
  final dynamic stats;
  const _DesktopStatRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: AppStrings.totalVolunteers,
            value: stats.totalVolunteers.toString(),
            change: '+${stats.volunteerGrowthPercent.toStringAsFixed(1)}%',
            icon: Icons.people_rounded,
            gradient: AppColors.primaryGradient,
            animationDelay: 200,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: AppStrings.activeEvents,
            value: stats.upcomingEvents.toString(),
            change: '${stats.totalEvents} total',
            icon: Icons.event_rounded,
            gradient: AppColors.cyanGradient,
            animationDelay: 300,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: AppStrings.hoursThisMonth,
            value: AppUtils.formatNumber(stats.hoursThisMonth),
            change: stats.hoursChangePercent,
            icon: Icons.schedule_rounded,
            gradient: AppColors.emeraldGradient,
            animationDelay: 400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: AppStrings.attendanceRate,
            value: '${stats.attendanceRate.toStringAsFixed(1)}%',
            change: stats.attendanceChangePercent,
            icon: Icons.fact_check_rounded,
            gradient: AppColors.amberGradient,
            animationDelay: 500,
          ),
        ),
      ],
    );
  }
}

class _AIInsightsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final stats = dash.stats;

    // Generate a dynamic insight message from real DB stats
    String insight;
    if (stats == null) {
      insight = 'Loading your personalized insights...';
    } else if (stats.upcomingEvents > 0 &&
        stats.totalVolunteers > 0 &&
        stats.attendanceRate < 80) {
      insight =
          'Attendance rate is ${stats.attendanceRate.toStringAsFixed(1)}% — '
          '${stats.upcomingEvents} upcoming event${stats.upcomingEvents > 1 ? 's' : ''} '
          'need${stats.upcomingEvents == 1 ? 's' : ''} more volunteers. '
          'Consider sending reminder notifications.';
    } else if (stats.newVolunteersThisMonth > 0) {
      insight =
          '${stats.newVolunteersThisMonth} new volunteer${stats.newVolunteersThisMonth > 1 ? 's' : ''} '
          'joined this month! You now have ${stats.totalVolunteers} volunteers '
          'with ${stats.attendanceRate.toStringAsFixed(1)}% attendance rate.';
    } else if (stats.upcomingEvents > 0) {
      insight =
          'You have ${stats.upcomingEvents} upcoming event${stats.upcomingEvents > 1 ? 's' : ''} '
          'across ${stats.totalEvents} total. '
          '${stats.activeVolunteers} active volunteers are ready to be assigned.';
    } else {
      insight =
          '${stats.totalVolunteers} total volunteers with '
          '${stats.attendanceRate.toStringAsFixed(1)}% attendance rate. '
          '${stats.hoursThisMonth} hours logged — great engagement this month!';
    }

    return GestureDetector(
      onTap: () => context.go(AppRouter.aiChat),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.15),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Volt AI Insight',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 3),
                  Text(
                    insight,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}

class _MobileChartsColumn extends StatelessWidget {
  final DashboardProvider dash;
  const _MobileChartsColumn({required this.dash});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Volunteer Growth',
                subtitle: 'Last 9 months',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: VolunteerGrowthChart(data: dash.monthlyVolunteers),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 700.ms),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Event Categories',
                subtitle: 'Distribution by type',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: CategoryPieChart(data: dash.categoryDistribution),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 800.ms),
      ],
    );
  }
}

class _DesktopChartsRow extends StatelessWidget {
  final DashboardProvider dash;
  const _DesktopChartsRow({required this.dash});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Volunteer Growth',
                  subtitle: 'Last 9 months',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: VolunteerGrowthChart(data: dash.monthlyVolunteers),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 700.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Categories',
                  subtitle: 'By event type',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: CategoryPieChart(data: dash.categoryDistribution),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),
        ),
      ],
    );
  }
}

class _MobileBottomSection extends StatelessWidget {
  final DashboardProvider dash;
  const _MobileBottomSection({required this.dash});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Weekly Attendance'),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: AttendanceBarChart(data: dash.weeklyAttendance),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 900.ms),
        const SizedBox(height: 16),
        _ActivityFeed(items: dash.activityFeed)
            .animate()
            .fadeIn(delay: 1000.ms),
      ],
    );
  }
}

class _DesktopBottomSection extends StatelessWidget {
  final DashboardProvider dash;
  const _DesktopBottomSection({required this.dash});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Weekly Attendance'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: AttendanceBarChart(data: dash.weeklyAttendance),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 900.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _ActivityFeed(items: dash.activityFeed)
              .animate()
              .fadeIn(delay: 1000.ms),
        ),
      ],
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _ActivityFeed({required this.items});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              title: 'Recent Activity', subtitle: 'Latest updates'),
          const SizedBox(height: 16),
          ...items.map((item) => _ActivityItem(item: item)),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ActivityItem({required this.item});

  IconData _icon(String type) {
    switch (type) {
      case 'volunteer_joined':
        return Icons.person_add_rounded;
      case 'event_created':
        return Icons.event_rounded;
      case 'attendance_logged':
        return Icons.check_circle_rounded;
      case 'report_generated':
        return Icons.analytics_rounded;
      case 'milestone':
        return Icons.emoji_events_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'volunteer_joined':
        return AppColors.primary;
      case 'event_created':
        return AppColors.accent1;
      case 'attendance_logged':
        return AppColors.accent2;
      case 'report_generated':
        return AppColors.accent3;
      case 'milestone':
        return AppColors.accent5;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = item['type'] as String;
    final c = _color(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon(type), color: c, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'] as String,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item['subtitle'] as String,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            AppUtils.timeAgo(item['time'] as DateTime),
            style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Live Indicator ────────────────────────────────────────────────────────────

class _LiveIndicator extends StatefulWidget {
  final bool connected;
  const _LiveIndicator({required this.connected});

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.connected ? const Color(0xFF10B981) : const Color(0xFF6B7280);
    return Tooltip(
      message: widget.connected ? 'Live — real-time updates on' : 'Connecting…',
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(
                    widget.connected ? _pulse.value : 0.4),
                shape: BoxShape.circle,
                boxShadow: widget.connected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5 * _pulse.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              widget.connected ? 'Live' : 'Syncing',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not load live data. Showing last known data.',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => context.read<DashboardProvider>().refresh(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
