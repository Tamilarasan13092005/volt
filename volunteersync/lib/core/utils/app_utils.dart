import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class AppUtils {
  // Responsive helpers
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  // Date formatting
  static String formatDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  static String formatDateShort(DateTime date) =>
      DateFormat('MMM dd').format(date);

  static String formatTime(DateTime time) =>
      DateFormat('h:mm a').format(time);

  static String formatDateTime(DateTime dt) =>
      DateFormat('MMM dd, yyyy • h:mm a').format(dt);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDateShort(date);
  }

  // Number formatting
  static String formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static String formatPercent(double n) => '${n.toStringAsFixed(1)}%';

  // Color from string
  static Color colorFromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'confirmed':
      case 'completed':
        return AppColors.accent2;
      case 'pending':
      case 'upcoming':
        return AppColors.accent3;
      case 'inactive':
      case 'cancelled':
        return AppColors.accent4;
      case 'draft':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
  }

  // Initials from name
  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.accent4 : AppColors.accent2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());
}
