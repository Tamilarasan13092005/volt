class AttendanceRecord {
  final String id;
  final String volunteerId;
  final String volunteerName;
  final String eventId;
  final String eventTitle;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String status; // present, absent, late, excused
  final String? notes;
  final int? hoursLogged;

  const AttendanceRecord({
    required this.id,
    required this.volunteerId,
    required this.volunteerName,
    required this.eventId,
    required this.eventTitle,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
    this.hoursLogged,
  });

  Duration get duration {
    if (checkOutTime == null) return Duration.zero;
    return checkOutTime!.difference(checkInTime);
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      volunteerId: json['volunteerId'] as String,
      volunteerName: json['volunteerName'] as String,
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      hoursLogged: json['hoursLogged'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'volunteerId': volunteerId,
        'volunteerName': volunteerName,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'checkInTime': checkInTime.toIso8601String(),
        'checkOutTime': checkOutTime?.toIso8601String(),
        'status': status,
        'notes': notes,
        'hoursLogged': hoursLogged,
      };
}

class AttendanceSummary {
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double rate;

  const AttendanceSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.rate,
  });
}
