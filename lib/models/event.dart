class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String category;
  final int targetVolunteers;
  final int registeredVolunteers;
  final int attendedVolunteers;
  final String organizer;
  final List<String> volunteerIds;
  final String imageUrl;
  final List<String> tags;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.category,
    required this.targetVolunteers,
    required this.registeredVolunteers,
    required this.attendedVolunteers,
    required this.organizer,
    required this.volunteerIds,
    required this.imageUrl,
    required this.tags,
  });

  double get fillRate =>
      targetVolunteers > 0
          ? (registeredVolunteers / targetVolunteers).clamp(0.0, 1.0)
          : 0.0;

  double get attendanceRate =>
      registeredVolunteers > 0
          ? (attendedVolunteers / registeredVolunteers).clamp(0.0, 1.0)
          : 0.0;

  bool get isPast => endDate.isBefore(DateTime.now());
  bool get isActive =>
      startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
  bool get isUpcoming => startDate.isAfter(DateTime.now());

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      category: json['category'] as String,
      targetVolunteers: json['targetVolunteers'] as int,
      registeredVolunteers: json['registeredVolunteers'] as int,
      attendedVolunteers: json['attendedVolunteers'] as int,
      organizer: json['organizer'] as String,
      volunteerIds: List<String>.from(json['volunteerIds'] as List),
      imageUrl: json['imageUrl'] as String,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'category': category,
        'targetVolunteers': targetVolunteers,
        'registeredVolunteers': registeredVolunteers,
        'attendedVolunteers': attendedVolunteers,
        'organizer': organizer,
        'volunteerIds': volunteerIds,
        'imageUrl': imageUrl,
        'tags': tags,
      };
}
