class Volunteer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String avatarUrl;
  final List<String> skills;
  final List<String> assignedEvents;
  final int totalHours;
  final double attendanceRate;
  final DateTime joinedDate;
  final String location;
  final String bio;

  const Volunteer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.avatarUrl,
    required this.skills,
    required this.assignedEvents,
    required this.totalHours,
    required this.attendanceRate,
    required this.joinedDate,
    required this.location,
    required this.bio,
  });

  factory Volunteer.fromJson(Map<String, dynamic> json) {
    return Volunteer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      avatarUrl: json['avatarUrl'] as String,
      skills: List<String>.from(json['skills'] as List),
      assignedEvents: List<String>.from(json['assignedEvents'] as List),
      totalHours: json['totalHours'] as int,
      attendanceRate: (json['attendanceRate'] as num).toDouble(),
      joinedDate: DateTime.parse(json['joinedDate'] as String),
      location: json['location'] as String,
      bio: json['bio'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'status': status,
        'avatarUrl': avatarUrl,
        'skills': skills,
        'assignedEvents': assignedEvents,
        'totalHours': totalHours,
        'attendanceRate': attendanceRate,
        'joinedDate': joinedDate.toIso8601String(),
        'location': location,
        'bio': bio,
      };

  Volunteer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? avatarUrl,
    List<String>? skills,
    List<String>? assignedEvents,
    int? totalHours,
    double? attendanceRate,
    DateTime? joinedDate,
    String? location,
    String? bio,
  }) {
    return Volunteer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      skills: skills ?? this.skills,
      assignedEvents: assignedEvents ?? this.assignedEvents,
      totalHours: totalHours ?? this.totalHours,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      joinedDate: joinedDate ?? this.joinedDate,
      location: location ?? this.location,
      bio: bio ?? this.bio,
    );
  }
}
