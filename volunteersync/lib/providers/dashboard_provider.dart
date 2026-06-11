import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/mock_data.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardStats? _stats;
  bool _isLoading = false;
  List<Map<String, dynamic>> _activityFeed = [];

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get activityFeed => _activityFeed;
  List<Map<String, dynamic>> get monthlyVolunteers => MockData.monthlyVolunteers;
  List<Map<String, dynamic>> get monthlyHours => MockData.monthlyHours;
  List<Map<String, dynamic>> get categoryDistribution => MockData.categoryDistribution;
  List<Map<String, dynamic>> get weeklyAttendance => MockData.weeklyAttendance;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    _stats = MockData.dashboardStats;
    _activityFeed = List.from(MockData.activityFeed);
    _isLoading = false;
    notifyListeners();
  }

  void refresh() => loadDashboard();
}
