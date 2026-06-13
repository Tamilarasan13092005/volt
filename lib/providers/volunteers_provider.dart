import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/volunteer.dart';

class VolunteersProvider extends ChangeNotifier {
  List<Volunteer> _volunteers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterStatus = 'all';

  final _supabase = Supabase.instance.client;

  List<Volunteer> get volunteers => _filtered;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  int get totalCount => _volunteers.length;
  int get activeCount => _volunteers.where((v) => v.status == 'active').length;

  List<Volunteer> get _filtered {
    var list = _volunteers;
    if (_filterStatus != 'all') {
      list = list.where((v) => v.status == _filterStatus).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((v) =>
              v.name.toLowerCase().contains(q) ||
              v.email.toLowerCase().contains(q) ||
              v.role.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<void> loadVolunteers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('volunteers')
          .select()
          .order('created_at', ascending: false);

      _volunteers = (response as List)
          .map<Volunteer>((item) => Volunteer(
                id: item['id'] ?? '',
                name: item['full_name'] ?? '',
                email: item['email'] ?? '',
                phone: item['phone'] ?? '',
                role: item['availability'] ?? 'Volunteer',
                status: item['status'] ?? 'active',
                avatarUrl: item['avatar_url'] ?? '',
                skills: List<String>.from(item['skills'] ?? []),
                assignedEvents: [],
                totalHours: (item['total_hours'] ?? 0).toInt(),
                attendanceRate: (item['rating'] ?? 0).toDouble(),
                joinedDate: DateTime.parse(
                    item['joined_date'] ?? DateTime.now().toIso8601String()),
                location: item['location'] ?? '',
                bio: item['bio'] ?? '',
              ))
          .toList();
    } catch (e) {
      debugPrint('Error loading volunteers: $e');
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

  Future<void> addVolunteer(Volunteer v) async {
    try {
      await _supabase.from('volunteers').insert({
        'full_name': v.name,
        'email': v.email,
        'phone': v.phone,
        'status': v.status,
        'skills': v.skills,
        'availability': v.role,
        'total_hours': v.totalHours,
        'rating': v.attendanceRate,
        'joined_date': v.joinedDate.toIso8601String(),
        'location': v.location,
        'bio': v.bio,
      });
      await loadVolunteers();
    } catch (e) {
      debugPrint('Error adding volunteer: $e');
    }
  }

  Future<void> updateVolunteer(Volunteer v) async {
    try {
      await _supabase.from('volunteers').update({
        'full_name': v.name,
        'email': v.email,
        'phone': v.phone,
        'status': v.status,
        'skills': v.skills,
        'availability': v.role,
        'total_hours': v.totalHours,
        'rating': v.attendanceRate,
        'location': v.location,
        'bio': v.bio,
      }).eq('id', v.id);
      await loadVolunteers();
    } catch (e) {
      debugPrint('Error updating volunteer: $e');
    }
  }

  Future<void> deleteVolunteer(String id) async {
    try {
      await _supabase.from('volunteers').delete().eq('id', id);
      await loadVolunteers();
    } catch (e) {
      debugPrint('Error deleting volunteer: $e');
    }
  }

  Volunteer? getById(String id) =>
      _volunteers.where((v) => v.id == id).firstOrNull;
}
