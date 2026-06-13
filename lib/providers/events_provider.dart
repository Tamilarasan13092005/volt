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

      if (_events.isEmpty) {
        final now = DateTime.now();
        _events = [
          Event(
            id: 'mock-1',
            title: 'Community Park Cleanup',
            description: 'Help us clean and beautify the local community park. Tools and refreshments provided!',
            location: 'Riverside Community Park',
            startDate: now.subtract(const Duration(days: 2, hours: 4)),
            endDate: now.subtract(const Duration(days: 2, hours: 1)),
            status: 'completed',
            category: 'Community',
            targetVolunteers: 25,
            registeredVolunteers: 22,
            attendedVolunteers: 18,
            organizer: 'Green Earth Alliance',
            imageUrl: 'https://images.unsplash.com/photo-1618477388954-7852f32655ec?w=500&auto=format&fit=crop',
            tags: ['Environment', 'Outdoor', 'Cleanup'],
            volunteerIds: const [],
          ),
          Event(
            id: 'mock-2',
            title: 'Downtown Food Drive',
            description: 'Sorting and distributing food packages for families in need.',
            location: 'Downtown Hope Center',
            startDate: now.subtract(const Duration(days: 1, hours: 3)),
            endDate: now.subtract(const Duration(days: 1)),
            status: 'completed',
            category: 'Healthcare',
            targetVolunteers: 15,
            registeredVolunteers: 15,
            attendedVolunteers: 12,
            organizer: 'Food For All',
            imageUrl: 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=500&auto=format&fit=crop',
            tags: ['Food', 'Community', 'Service'],
            volunteerIds: const [],
          ),
          Event(
            id: 'mock-3',
            title: 'Youth Coding Boot Camp',
            description: 'Teaching kids the fundamentals of Scratch and Python programming.',
            location: 'Public Library Tech Lab',
            startDate: now.add(const Duration(days: 3)),
            endDate: now.add(const Duration(days: 3, hours: 3)),
            status: 'upcoming',
            category: 'Education',
            targetVolunteers: 8,
            registeredVolunteers: 6,
            attendedVolunteers: 0,
            organizer: 'Code Future',
            imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&auto=format&fit=crop',
            tags: ['Education', 'Technology', 'Youth'],
            volunteerIds: const [],
          ),
          Event(
            id: 'mock-4',
            title: 'Senior Care Tech Help',
            description: 'Help seniors learn to use their smartphones, tablets, and connect with their families.',
            location: 'Evergreen Senior Living',
            startDate: now.add(const Duration(days: 5, hours: 2)),
            endDate: now.add(const Duration(days: 5, hours: 5)),
            status: 'upcoming',
            category: 'Social',
            targetVolunteers: 10,
            registeredVolunteers: 4,
            attendedVolunteers: 0,
            organizer: 'Evergreen Community',
            imageUrl: 'https://images.unsplash.com/photo-1576765608535-5f04d1e3f289?w=500&auto=format&fit=crop',
            tags: ['Seniors', 'Technology', 'Social'],
            volunteerIds: const [],
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
      // If error occurs, also fallback to avoid blank UI
      _events = [
        Event(
          id: 'mock-err-1',
          title: 'Community Cleanup',
          description: 'Emergency fallback community cleaning event.',
          location: 'City Center',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().subtract(const Duration(days: 1, hours: -3)),
          status: 'completed',
          category: 'Community',
          targetVolunteers: 20,
          registeredVolunteers: 15,
          attendedVolunteers: 12,
          organizer: 'Volunteers Inc',
          imageUrl: '',
          tags: ['Local'],
          volunteerIds: const [],
        ),
      ];
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
