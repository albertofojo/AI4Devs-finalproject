import '../setlists/setlist_models.dart';

class AttendanceSummary {
  AttendanceSummary({
    this.confirmed = 0,
    this.absent = 0,
    this.maybe = 0,
    this.pending = 0,
  });

  final int confirmed;
  final int absent;
  final int maybe;
  final int pending;

  factory AttendanceSummary.fromJson(Map<String, dynamic> j) => AttendanceSummary(
        confirmed: j['confirmed'] as int? ?? 0,
        absent: j['absent'] as int? ?? 0,
        maybe: j['maybe'] as int? ?? 0,
        pending: j['pending'] as int? ?? 0,
      );
}

class Rehearsal {
  Rehearsal({
    required this.id,
    required this.groupId,
    required this.title,
    required this.startsAt,
    this.location,
    this.notes,
    this.setlist,
    this.setlistId,
    AttendanceSummary? summary,
    this.myAttendance,
  }) : summary = summary ?? AttendanceSummary();

  final String id;
  final String groupId;
  final String title;
  final DateTime startsAt;
  final String? location;
  final String? notes;
  final Setlist? setlist;
  final String? setlistId;
  final AttendanceSummary summary;
  final String? myAttendance;

  factory Rehearsal.fromJson(Map<String, dynamic> j) => Rehearsal(
        id: j['id'] as String,
        groupId: j['group_id'] as String,
        title: j['title'] as String,
        startsAt: DateTime.parse(j['starts_at'] as String),
        location: j['location'] as String?,
        notes: j['notes'] as String?,
        setlistId: j['setlist_id'] as String?,
        setlist: j['setlist'] != null
            ? Setlist.fromJson(j['setlist'] as Map<String, dynamic>)
            : null,
        summary: j['attendance_summary'] != null
            ? AttendanceSummary.fromJson(
                j['attendance_summary'] as Map<String, dynamic>)
            : null,
        myAttendance: j['my_attendance'] as String?,
      );
}
