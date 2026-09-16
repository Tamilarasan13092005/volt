import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/event.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../widgets/cards/stat_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EventsProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isVolunteer = user?.role == 'volunteer';
    
    final categoryMap = {
      'Food Donation': 'Food Donor',
      'Blood Donation': 'Blood Donor',
      'Medical Assistance': 'Medical Volunteer',
      'Transportation': 'Driver / Transportation',
      'Clothing Donation': 'Clothing Donor',
      'Fundraising': 'Fundraiser',
      'General Volunteering': 'General Volunteer',
    };

    final displayEvents = isVolunteer
        ? prov.events.where((e) {
            final userCategory = user?.category ?? 'General Volunteer';
            final requiredVolunteerCategory = categoryMap[e.category] ?? '';
            return userCategory.toLowerCase() == requiredVolunteerCategory.toLowerCase();
          }).toList()
        : prov.events.where((e) => e.organizer.toLowerCase() == (user?.name ?? '').toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
                          Text('Volunteer Activities',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const Text('Manage all volunteer activities',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                    if (!isVolunteer)
                      GradientButton(
                        label: 'New Activity',
                        onPressed: () => _showAddDialog(context),
                        icon: Icons.add_rounded,
                      ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),
                AppSearchBar(
                  hint: 'Search activities...',
                  onChanged: prov.setSearch,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                FilterChipRow(
                  options: const ['all', 'upcoming', 'completed'],
                  selected: prov.filterStatus,
                  onSelected: prov.setFilter,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: prov.isLoading
                ? _buildShimmer()
                : displayEvents.isEmpty
                    ? EmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'No activities found',
                        subtitle: isVolunteer
                            ? 'No activities are available right now'
                            : 'Create your first activity to get started',
                        actionLabel: isVolunteer ? null : 'Create Activity',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: displayEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _EventCard(
                          event: displayEvents[i],
                          index: i,
                          onTap: () => _showDetail(ctx, displayEvents[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() => ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) =>
            const ShimmerBox(width: double.infinity, height: 140),
      );

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddEventDialog(),
    );
  }

  void _showDetail(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _EventDetailSheet(event: event),
    );
  }
}

class _AddEventDialog extends StatefulWidget {
  const _AddEventDialog();

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _category = 'General Volunteering';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _organizerCtrl.text = auth.user?.name ?? '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _organizerCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (t == null) return;
    setState(() {
      _startDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _pickEndDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDate),
    );
    if (t == null) return;
    setState(() {
      _endDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Activity',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Activity Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _organizerCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Organizer'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Target Volunteers'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  'Food Donation',
                  'Blood Donation',
                  'Medical Assistance',
                  'Transportation',
                  'Clothing Donation',
                  'Fundraising',
                  'General Volunteering',
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartDateTime,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date & Time',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(AppUtils.formatDateTime(_startDate),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndDateTime,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date & Time',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(AppUtils.formatDateTime(_endDate),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    label: 'Create',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final event = Event(
                          id: '',
                          title: _titleCtrl.text.trim(),
                          description: _descCtrl.text.trim(),
                          location: _locationCtrl.text.trim(),
                          startDate: _startDate,
                          endDate: _endDate,
                          status: 'upcoming',
                          category: _category,
                          targetVolunteers: int.tryParse(_targetCtrl.text) ?? 0,
                          registeredVolunteers: 0,
                          attendedVolunteers: 0,
                          organizer: _organizerCtrl.text.trim(),
                          volunteerIds: [],
                          imageUrl: '',
                          tags: [],
                        );
                        await context.read<EventsProvider>().addEvent(event);
                        if (context.mounted) {
                           Navigator.pop(context);
                          AppUtils.showSnackBar(
                              context, 'Activity created successfully!');
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditEventDialog extends StatefulWidget {
  final Event event;
  const _EditEventDialog({required this.event});

  @override
  State<_EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<_EditEventDialog> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.event.title;
    _locationCtrl.text = widget.event.location;
    _organizerCtrl.text = widget.event.organizer;
    _descCtrl.text = widget.event.description;
    _targetCtrl.text = widget.event.targetVolunteers.toString();
    _category = widget.event.category;
    _startDate = widget.event.startDate;
    _endDate = widget.event.endDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _organizerCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (t == null) return;
    setState(() {
      _startDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _pickEndDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDate),
    );
    if (t == null) return;
    setState(() {
      _endDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Activity',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Activity Title'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _organizerCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Organizer'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration:
                    const InputDecoration(labelText: 'Target Volunteers'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  'Food Donation',
                  'Blood Donation',
                  'Medical Assistance',
                  'Transportation',
                  'Clothing Donation',
                  'Fundraising',
                  'General Volunteering',
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartDateTime,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date & Time',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(AppUtils.formatDateTime(_startDate),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndDateTime,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date & Time',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(AppUtils.formatDateTime(_endDate),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 12),
                  GradientButton(
                    label: 'Save',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final updatedEvent = Event(
                          id: widget.event.id,
                          title: _titleCtrl.text.trim(),
                          description: _descCtrl.text.trim(),
                          location: _locationCtrl.text.trim(),
                          startDate: _startDate,
                          endDate: _endDate,
                          status: widget.event.status,
                          category: _category,
                          targetVolunteers: int.tryParse(_targetCtrl.text) ?? 0,
                          registeredVolunteers: widget.event.registeredVolunteers,
                          attendedVolunteers: widget.event.attendedVolunteers,
                          organizer: _organizerCtrl.text.trim(),
                          volunteerIds: widget.event.volunteerIds,
                          imageUrl: widget.event.imageUrl,
                          tags: widget.event.tags,
                        );
                        await context.read<EventsProvider>().updateEvent(updatedEvent);
                        if (context.mounted) {
                          Navigator.pop(context, true);
                          AppUtils.showSnackBar(
                              context, 'Activity updated successfully!');
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final int index;
  final VoidCallback onTap;

  const _EventCard(
      {required this.event, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.colorFromStatus(event.status);
    final categoryColors = {
      'Food Donation': AppColors.accent3,
      'Blood Donation': AppColors.accent4,
      'Medical Assistance': AppColors.accent5,
      'Transportation': AppColors.primary,
      'Clothing Donation': AppColors.secondary,
      'Fundraising': AppColors.accent1,
      'General Volunteering': AppColors.accent2,
    };
    final catColor = categoryColors[event.category] ?? AppColors.primary;

    String getCardLabel(String category) {
      switch (category) {
        case 'Food Donation':
          return 'Food Donation Required';
        case 'Blood Donation':
          return 'Blood Donor Required';
        case 'Medical Assistance':
          return 'Medical Volunteer Required';
        case 'Transportation':
          return 'Transportation Required';
        case 'Clothing Donation':
          return 'Clothing Donation Required';
        case 'Fundraising':
          return 'Fundraising Required';
        case 'General Volunteering':
          return 'General Volunteer Required';
        default:
          return '$category Required';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.event_rounded, color: catColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: catColor.withOpacity(0.2), width: 0.8),
                        ),
                        child: Text(
                          getCardLabel(event.category),
                          style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: event.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.textDisabled),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(event.location,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.textDisabled),
                const SizedBox(width: 4),
                Text(AppUtils.formatDate(event.startDate),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 13, color: AppColors.textDisabled),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              '${event.registeredVolunteers}/${event.targetVolunteers} volunteers',
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                          Text('${(event.fillRate * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  color: event.fillRate > 0.8
                                      ? AppColors.accent2
                                      : AppColors.accent3,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: event.fillRate,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.fillRate > 0.8
                                ? AppColors.accent2
                                : AppColors.accent3,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1);
  }
}

class _EventDetailSheet extends StatefulWidget {
  final Event event;
  const _EventDetailSheet({required this.event});

  @override
  State<_EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends State<_EventDetailSheet> {
  final _supabase = Supabase.instance.client;
  String _status = 'loading';
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _participants = [];
  Map<String, String> _participantCategories = {};
  String _filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    setState(() => _status = 'loading');

    try {
      if (user.role == 'volunteer') {
        final res = await _supabase
            .from('attendance')
            .select('status')
            .eq('event_id', widget.event.id)
            .eq('volunteer_id', user.id)
            .maybeSingle();

        setState(() {
          _status = res != null ? (res['status'] ?? 'none') : 'none';
        });
      } else {
        final res = await _supabase
            .from('attendance')
            .select()
            .eq('event_id', widget.event.id);

        final participantIds = res.map((p) => p['volunteer_id'] as String).toList();
        Map<String, String> volunteerCategories = {};
        if (participantIds.isNotEmpty) {
          try {
            final volRes = await _supabase
                .from('volunteers')
                .select('id, availability')
                .inFilter('id', participantIds);
            for (var v in volRes) {
              if (v['id'] != null && v['availability'] != null) {
                volunteerCategories[v['id'] as String] = v['availability'] as String;
              }
            }
          } catch (e) {
            debugPrint('Error fetching participant categories: $e');
          }
        }

        setState(() {
          _participants = List<Map<String, dynamic>>.from(res);
          _participantCategories = volunteerCategories;
          _status = 'organizer';
        });
      }
    } catch (e) {
      debugPrint('Error loading event status: $e');
      setState(() {
        _status = user.role == 'volunteer' ? 'none' : 'organizer';
      });
    }
  }

  Future<void> _requestToJoin() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final categoryMap = {
      'Food Donation': 'Food Donor',
      'Blood Donation': 'Blood Donor',
      'Medical Assistance': 'Medical Volunteer',
      'Transportation': 'Driver / Transportation',
      'Clothing Donation': 'Clothing Donor',
      'Fundraising': 'Fundraiser',
      'General Volunteering': 'General Volunteer',
    };
    final requiredVolunteerCategory = categoryMap[widget.event.category] ?? '';
    final userCategory = user.category;

    if (userCategory.toLowerCase() != 'general volunteer' &&
        userCategory.toLowerCase() != requiredVolunteerCategory.toLowerCase()) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Validation failed: You can only register for events matching your category ($requiredVolunteerCategory).',
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _supabase.from('attendance').insert({
        'volunteer_id': user.id,
        'volunteer_name': user.name,
        'event_id': widget.event.id,
        'event_title': widget.event.title,
        'status': 'requested',
        'checked_in_at': null,
        'hours_logged': 0,
      });

      final currentReg = widget.event.registeredVolunteers;
      await _supabase.from('events').update({
        'registered_volunteers': currentReg + 1,
      }).eq('id', widget.event.id);

      if (mounted) {
        await context.read<EventsProvider>().loadEvents();
      }

      setState(() {
        _status = 'requested';
      });
      if (mounted) {
        AppUtils.showSnackBar(context, 'Join request sent successfully!');
      }
    } catch (e) {
      debugPrint('Join request error: $e');
      if (mounted) {
        AppUtils.showSnackBar(context, 'Failed to send request. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _leaveEvent() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      await _supabase
          .from('attendance')
          .delete()
          .eq('event_id', widget.event.id)
          .eq('volunteer_id', user.id);

      final currentReg = widget.event.registeredVolunteers;
      await _supabase.from('events').update({
        'registered_volunteers': (currentReg - 1).clamp(0, 999999),
      }).eq('id', widget.event.id);

      if (mounted) {
        await context.read<EventsProvider>().loadEvents();
      }

      setState(() {
        _status = 'none';
      });
      if (mounted) {
        AppUtils.showSnackBar(context, 'You have left the event.');
      }
    } catch (e) {
      debugPrint('Leave event error: $e');
      if (mounted) {
        AppUtils.showSnackBar(context, 'Failed to leave event.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _approveRequest(Map<String, dynamic> participant) async {
    try {
      await _supabase
          .from('attendance')
          .update({'status': 'joined'})
          .eq('id', participant['id']);

      await _loadDetails();
      if (mounted) {
        AppUtils.showSnackBar(context, 'Approved request for ${participant['volunteer_name']}');
      }
    } catch (e) {
      debugPrint('Approve error: $e');
    }
  }

  Future<void> _declineRequest(Map<String, dynamic> participant) async {
    try {
      await _supabase
          .from('attendance')
          .delete()
          .eq('id', participant['id']);

      final currentReg = widget.event.registeredVolunteers;
      await _supabase.from('events').update({
        'registered_volunteers': (currentReg - 1).clamp(0, 999999),
      }).eq('id', widget.event.id);

      if (mounted) {
        await context.read<EventsProvider>().loadEvents();
      }

      await _loadDetails();
      if (mounted) {
        AppUtils.showSnackBar(context, 'Declined request.');
      }
    } catch (e) {
      debugPrint('Decline error: $e');
    }
  }

  Future<void> _markAttendance(Map<String, dynamic> participant, String status) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      final hours = widget.event.endDate.difference(widget.event.startDate).inHours;

      await _supabase
          .from('attendance')
          .update({
            'status': status,
            'checked_in_at': nowStr,
            'hours_logged': status == 'present' || status == 'late' ? hours : 0,
          })
          .eq('id', participant['id']);

      final updatedRes = await _supabase
          .from('attendance')
          .select('status')
          .eq('event_id', widget.event.id);

      final presentCount = (updatedRes as List)
          .where((p) => p['status'] == 'present' || p['status'] == 'late')
          .length;

      await _supabase.from('events').update({
        'attended_volunteers': presentCount,
      }).eq('id', widget.event.id);

      if (mounted) {
        await context.read<EventsProvider>().loadEvents();
      }

      await _loadDetails();
      if (mounted) {
        AppUtils.showSnackBar(context, 'Marked ${participant['volunteer_name']} as $status');
      }
    } catch (e) {
      debugPrint('Mark attendance error: $e');
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'present':
        return AppColors.accent2;
      case 'late':
        return AppColors.accent3;
      case 'absent':
        return AppColors.accent4;
      case 'requested':
        return AppColors.accent1;
      case 'joined':
        return AppColors.primaryLight;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'late':
        return Icons.watch_later_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.colorFromStatus(widget.event.status);
    final auth = context.read<AuthProvider>();
    final isVolunteer = auth.user?.role == 'volunteer';
    final isCreator = auth.user?.role == 'organizer' && widget.event.organizer.toLowerCase() == (auth.user?.name ?? '').toLowerCase();

    final categoryMap = {
      'Food Donation': 'Food Donor',
      'Blood Donation': 'Blood Donor',
      'Medical Assistance': 'Medical Volunteer',
      'Transportation': 'Driver / Transportation',
      'Clothing Donation': 'Clothing Donor',
      'Fundraising': 'Fundraiser',
      'General Volunteering': 'General Volunteer',
    };
    final requiredVolunteerCategory = categoryMap[widget.event.category] ?? '';
    final userCategory = auth.user?.category ?? 'General Volunteer';
    final isCategoryMatched = userCategory.toLowerCase() == 'general volunteer' ||
        userCategory.toLowerCase() == requiredVolunteerCategory.toLowerCase();

    String getPluralCategoryName(String cat) {
      if (cat == 'Driver / Transportation') return 'Drivers / Transportation Volunteers';
      return '${cat}s';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.event.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(widget.event.category,
                                  style: const TextStyle(
                                      color: AppColors.primary, fontSize: 12)),
                            ],
                          ),
                        ),
                        StatusBadge(label: widget.event.status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Requirements Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isCategoryMatched
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.accent4.withOpacity(0.08),
                        border: Border.all(
                          color: isCategoryMatched
                              ? AppColors.primary.withOpacity(0.2)
                              : AppColors.accent4.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCategoryMatched
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.warning_amber_rounded,
                                color: isCategoryMatched ? AppColors.primaryLight : AppColors.accent4,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Requires: $requiredVolunteerCategory',
                                  style: TextStyle(
                                    color: isCategoryMatched ? AppColors.textPrimary : AppColors.accent4,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your registered category: $userCategory',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(widget.event.description,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                            height: 1.6)),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    _row(
                        Icons.location_on_outlined, 'Location', widget.event.location),
                    _row(Icons.calendar_today_outlined, 'Start',
                        AppUtils.formatDateTime(widget.event.startDate)),
                    _row(Icons.event_outlined, 'End',
                        AppUtils.formatDateTime(widget.event.endDate)),
                    _row(Icons.person_outlined, 'Organizer', widget.event.organizer),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: KpiCard(
                          label: 'Registered',
                          value:
                              '${widget.event.registeredVolunteers}/${widget.event.targetVolunteers}',
                          color: AppColors.primary,
                          progressValue: widget.event.fillRate,
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: KpiCard(
                          label: 'Attended',
                          value: widget.event.attendedVolunteers > 0
                              ? '${(widget.event.attendanceRate * 100).toStringAsFixed(0)}%'
                              : 'N/A',
                          color: AppColors.accent2,
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (widget.event.tags.isNotEmpty) ...[
                      const Text('Tags',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: widget.event.tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text('#$t',
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11)),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Volunteer Enrollment Panel
                    if (isVolunteer) ...[
                      const Text(
                        'My Participation',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_status == 'loading')
                        const Center(child: CircularProgressIndicator())
                      else if (_status == 'none') ...[
                        if (isCategoryMatched)
                          GradientButton(
                            label: 'Register as $requiredVolunteerCategory',
                            onPressed: _isSubmitting ? () {} : _requestToJoin,
                            width: double.infinity,
                            isLoading: _isSubmitting,
                            icon: Icons.rocket_launch_rounded,
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accent4.withOpacity(0.3)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'This event is currently accepting only ${getPluralCategoryName(requiredVolunteerCategory)}.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.accent4,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ]
                      else if (_status == 'requested')
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.accent1.withOpacity(0.1),
                                border: Border.all(color: AppColors.accent1.withOpacity(0.25)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.pending_actions_rounded, color: AppColors.accent1),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your join request is pending approval by the organizer.',
                                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _isSubmitting ? null : _leaveEvent,
                              icon: const Icon(Icons.cancel_outlined, color: AppColors.accent4),
                              label: const Text('Cancel Request', style: TextStyle(color: AppColors.accent4)),
                            ),
                          ],
                        )
                      else if (_status == 'joined')
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryLight),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'You are registered for this activity! Organizer will mark attendance when the activity starts.',
                                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _isSubmitting ? null : _leaveEvent,
                              icon: const Icon(Icons.logout_rounded, color: AppColors.accent4),
                              label: const Text('Leave Activity', style: TextStyle(color: AppColors.accent4)),
                            ),
                          ],
                        )
                      else ...[
                        // present, absent, late, excused
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _statusColor(_status).withOpacity(0.1),
                            border: Border.all(color: _statusColor(_status).withOpacity(0.25)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(_statusIcon(_status), color: _statusColor(_status)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _status == 'present'
                                      ? 'Your attendance: PARTICIPATED'
                                      : _status == 'absent'
                                          ? 'Your attendance: NOT PARTICIPATED'
                                          : 'Your attendance: ${_status.toUpperCase()}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // Organizer Panel
                    if (!isVolunteer) ...[
                      if (isCreator) ...[
                        Column(
                          children: [
                            if (widget.event.status != 'completed') ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.accent2,
                                  side: const BorderSide(color: AppColors.accent2),
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: const Text('Complete Activity'),
                                onPressed: () async {
                                  final provider = context.read<EventsProvider>();
                                  final navigator = Navigator.of(context);
                                  final messenger = ScaffoldMessenger.of(context);
                                  await provider.completeEvent(widget.event.id);
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text('Activity marked as completed!')),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primaryLight,
                                      side: const BorderSide(color: AppColors.primaryLight),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    label: const Text('Edit Activity'),
                                    onPressed: () async {
                                      final navigator = Navigator.of(context);
                                      final updated = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => _EditEventDialog(event: widget.event),
                                      );
                                      if (updated == true) {
                                        navigator.pop();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.accent4,
                                      side: const BorderSide(color: AppColors.accent4),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    label: const Text('Delete Activity'),
                                    onPressed: () async {
                                      final provider = context.read<EventsProvider>();
                                      final navigator = Navigator.of(context);
                                      final messenger = ScaffoldMessenger.of(context);
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: AppColors.surface,
                                          title: const Text('Delete Activity', style: TextStyle(color: AppColors.textPrimary)),
                                          content: Text('Are you sure you want to delete "${widget.event.title}"?', style: const TextStyle(color: AppColors.textSecondary)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted))),
                                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppColors.accent4))),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await provider.deleteEvent(widget.event.id);
                                        navigator.pop();
                                        messenger.showSnackBar(
                                          const SnackBar(content: Text('Activity deleted successfully!')),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Participants & Join Requests',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _filterCategory,
                            dropdownColor: AppColors.surface,
                            icon: const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primaryLight),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Specializations')),
                              DropdownMenuItem(value: 'Food Donor', child: Text('Food Donors')),
                              DropdownMenuItem(value: 'Blood Donor', child: Text('Blood Donors')),
                              DropdownMenuItem(value: 'Medical Volunteer', child: Text('Medical Volunteers')),
                              DropdownMenuItem(value: 'Driver / Transportation', child: Text('Drivers')),
                              DropdownMenuItem(value: 'Clothing Donor', child: Text('Clothing Donors')),
                              DropdownMenuItem(value: 'Fundraiser', child: Text('Fundraisers')),
                              DropdownMenuItem(value: 'General Volunteer', child: Text('General Volunteers')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _filterCategory = v);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_status == 'loading')
                        const Center(child: CircularProgressIndicator())
                      else if (_participants.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No registered participants yet.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        )
                      else ...[
                        () {
                          final filtered = _filterCategory == 'All'
                              ? _participants
                              : _participants.where((p) {
                                  final cat = _participantCategories[p['volunteer_id']] ?? 'General Volunteer';
                                  return cat.toLowerCase() == _filterCategory.toLowerCase();
                                }).toList();

                          if (filtered.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'No participants match this category.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (ctx, idx) {
                              final p = filtered[idx];
                              final statusStr = p['status'] ?? 'joined';
                              final volunteerCat = _participantCategories[p['volunteer_id']] ?? 'General Volunteer';

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    AppAvatar(name: p['volunteer_name'] ?? 'U', radius: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  p['volunteer_name'] ?? 'Volunteer',
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  volunteerCat,
                                                  style: const TextStyle(
                                                    color: AppColors.primaryLight,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            statusStr == 'present'
                                                ? 'PARTICIPATED'
                                                : statusStr == 'absent'
                                                    ? 'NOT PARTICIPATED'
                                                    : statusStr.toString().toUpperCase(),
                                            style: TextStyle(
                                              color: _statusColor(statusStr),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (statusStr == 'requested') ...[
                                      IconButton(
                                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.accent2, size: 22),
                                        onPressed: () => _approveRequest(p),
                                        tooltip: 'Approve Request',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel_rounded, color: AppColors.accent4, size: 22),
                                        onPressed: () => _declineRequest(p),
                                        tooltip: 'Decline Request',
                                      ),
                                    ] else if (statusStr == 'joined') ...[
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.check_box_outlined, color: AppColors.primaryLight, size: 20),
                                        onSelected: (val) => _markAttendance(p, val),
                                        color: AppColors.surface,
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(value: 'present', child: Text('Participated', style: TextStyle(color: AppColors.textPrimary))),
                                          const PopupMenuItem(value: 'absent', child: Text('Not Participated', style: TextStyle(color: AppColors.textPrimary))),
                                        ],
                                        tooltip: 'Mark Attendance',
                                      ),
                                    ] else ...[
                                      Icon(_statusIcon(statusStr), color: _statusColor(statusStr), size: 20),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        }(),
                      ],
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Text('$label: ',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ),
          ],
        ),
      );
}
