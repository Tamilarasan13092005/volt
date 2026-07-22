import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../widgets/cards/stat_card.dart';
import '../../../widgets/charts/chart_widgets.dart';
import '../../../widgets/common/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final _periods = ['This Week', 'This Month', 'Last 6 Months', 'All Time'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final isMobile = AppUtils.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reports & Analytics',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const Text('Insights & performance metrics',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 14)),
                          ],
                        ),
                      ),
                      GradientButton(
                        label: 'Refresh',
                        onPressed: () {
                          context.read<DashboardProvider>().loadDashboard();
                          AppUtils.showSnackBar(context, 'Data refreshed!');
                        },
                        icon: Icons.refresh_rounded,
                        gradient: AppColors.emeraldGradient,
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  // Period selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _periods.map((p) {
                        final isSelected = p == _selectedPeriod;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(p,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // KPI row
                  if (dash.stats != null) ...[
                    isMobile
                        ? GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              StatCard(
                                label: 'Total Volunteers',
                                value: dash.stats!.totalVolunteers.toString(),
                                change:
                                    '+${dash.stats!.volunteerGrowthPercent.toStringAsFixed(1)}%',
                                icon: Icons.people_rounded,
                                gradient: AppColors.primaryGradient,
                                animationDelay: 300,
                              ),
                              StatCard(
                                label: 'Activities Run',
                                value: dash.stats!.totalEvents.toString(),
                                change:
                                    '${dash.stats!.upcomingEvents} upcoming',
                                icon: Icons.event_rounded,
                                gradient: AppColors.cyanGradient,
                                animationDelay: 600,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                  child: StatCard(
                                label: 'Total Volunteers',
                                value: dash.stats!.totalVolunteers.toString(),
                                change:
                                    '+${dash.stats!.volunteerGrowthPercent.toStringAsFixed(1)}%',
                                icon: Icons.people_rounded,
                                gradient: AppColors.primaryGradient,
                                animationDelay: 300,
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: StatCard(
                                label: 'Activities Run',
                                value: dash.stats!.totalEvents.toString(),
                                change:
                                    '${dash.stats!.upcomingEvents} upcoming',
                                icon: Icons.event_rounded,
                                gradient: AppColors.cyanGradient,
                                animationDelay: 600,
                              )),
                            ],
                          ),
                    const SizedBox(height: 28),
                  ],

                  // Volunteer Growth Chart
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Volunteer Growth',
                          subtitle: 'Cumulative volunteer count',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: VolunteerGrowthChart(
                              data: dash.monthlyVolunteers),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 16),

                  // Chart
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Activity Categories'),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: CategoryPieChart(
                              data: dash.categoryDistribution),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
