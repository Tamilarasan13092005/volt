import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventsProvider extends ChangeNotifier {
  List<Event> _events = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterStatus = 'All';
  String get filterStatus => _filterStatus;

  final _supabase = Supabase.instance.client;

  List<Event> get events => _filtered;
  bool get isLoading => _isLoading;
  List<Event> get upcomingEvents => _events.where((e) => e.isUpcoming).toList();
  List<Event> get completedEvents => _events.where((e) => e.isPast).toList();

  List<Event> get _filtered {
    var list = _events;
    if (_filterStatus != 'All') {
      list = list.where((e) => e.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.location.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('start_date', ascending: false);

      _events = (response as List)
          .map<Event>((item) => Event(
                id: item['id'] ?? '',
                title: item['title'] ?? '',
                description: item['description'] ?? '',
                location: item['location'] ?? '',
                startDate: DateTime.parse(
                    item['start_date'] ?? DateTime.now().toIso8601String()),
                endDate: DateTime.parse(
                    item['end_date'] ?? DateTime.now().toIso8601String()),
                status: item['status'] ?? 'upcoming',
                category: item['category'] ?? '',
                targetVolunteers: item['target_volunteers'] ?? 0,
                registeredVolunteers: item['registered_volunteers'] ?? 0,
                attendedVolunteers: item['attended_volunteers'] ?? 0,
                organizer: item['organizer'] ?? '',
                volunteerIds: [],
                imageUrl: item['image_url'] ?? '',
                tags: List<String>.from(item['tags'] ?? []),
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading events: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> addEvent(Event e) async {
    try {
      await _supabase.from('events').insert({
        'title': e.title,
        'description': e.description,
        'location': e.location,
        'start_date': e.startDate.toIso8601String(),
        'end_date': e.endDate.toIso8601String(),
        'status': e.status,
        'category': e.category,
        'target_volunteers': e.targetVolunteers,
        'registered_volunteers': e.registeredVolunteers,
        'attended_volunteers': e.attendedVolunteers,
        'organizer': e.organizer,
        'image_url': e.imageUrl,
        'tags': e.tags,
      });
      await loadEvents();
    } catch (e) {
      debugPrint('Error adding event: $e');
    }
  }

  Future<void> updateEvent(Event e) async {
    try {
      await _supabase.from('events').update({
        'title': e.title,
        'description': e.description,
        'location': e.location,
        'start_date': e.startDate.toIso8601String(),
        'end_date': e.endDate.toIso8601String(),
        'status': e.status,
        'category': e.category,
        'target_volunteers': e.targetVolunteers,
        'registered_volunteers': e.registeredVolunteers,
        'attended_volunteers': e.attendedVolunteers,
        'organizer': e.organizer,
        'image_url': e.imageUrl,
        'tags': e.tags,
      }).eq('id', e.id);
      await loadEvents();
    } catch (e) {
      debugPrint('Error updating event: $e');
    }
  }

  Event? getById(String id) => _events.where((e) => e.id == id).firstOrNull;
}
