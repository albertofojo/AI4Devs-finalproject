import '../features/groups/group_models.dart';
import '../features/rehearsals/rehearsal_models.dart';
import '../features/scores/score_models.dart';
import '../features/setlists/setlist_models.dart';
import 'api_client.dart';

/// Repositorio de datos: traduce las respuestas del API a modelos de dominio.
/// Es el único punto por el que las pantallas hablan con el backend.
class DataRepository {
  DataRepository(this._api);
  final ApiClient _api;

  // ---- Grupos (HU-02) ----
  Future<List<Group>> fetchGroups() async {
    final data = await _api.get('/api/groups') as List;
    return data.map((e) => Group.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Group> createGroup(String name, String type, String? description) async {
    final data = await _api.post('/api/groups', {
      'name': name,
      'type': type,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    return Group.fromJson(data as Map<String, dynamic>);
  }

  Future<Group> getGroup(String id) async {
    final data = await _api.get('/api/groups/$id');
    return Group.fromJson(data as Map<String, dynamic>);
  }

  // ---- Invitaciones (HU-03) ----
  Future<String> createInvitation(String groupId, String email) async {
    final data = await _api.post('/api/groups/$groupId/invitations', {'email': email});
    return (data as Map<String, dynamic>)['token'] as String;
  }

  Future<void> acceptInvitation(String token) async {
    await _api.post('/api/invitations/$token/accept');
  }

  // ---- Partituras (HU-04) ----
  Future<List<Score>> fetchScores(String groupId) async {
    final data = await _api.get('/api/groups/$groupId/scores') as List;
    return data.map((e) => Score.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Score> createScore(
    String groupId, {
    required String title,
    required String format,
    required String fileUrl,
    String? composer,
    String? keySignature,
  }) async {
    final data = await _api.post('/api/groups/$groupId/scores', {
      'title': title,
      'format': format,
      'file_url': fileUrl,
      if (composer != null && composer.isNotEmpty) 'composer': composer,
      if (keySignature != null && keySignature.isNotEmpty) 'key_signature': keySignature,
    });
    return Score.fromJson(data as Map<String, dynamic>);
  }

  // ---- Setlists (HU-05) ----
  Future<Setlist> createSetlist(String groupId, String name, String? description) async {
    final data = await _api.post('/api/groups/$groupId/setlists', {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    return Setlist.fromJson(data as Map<String, dynamic>);
  }

  Future<Setlist> getSetlist(String id) async {
    final data = await _api.get('/api/setlists/$id');
    return Setlist.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Setlist>> fetchSetlists(String groupId) async {
    final data = await _api.get('/api/groups/$groupId/setlists') as List;
    return data.map((e) => Setlist.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Setlist> addSetlistItem(String setlistId, String scoreId, String? notes) async {
    final data = await _api.post('/api/setlists/$setlistId/items', {
      'score_id': scoreId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return Setlist.fromJson(data as Map<String, dynamic>);
  }

  // ---- Ensayos y asistencia (HU-05, HU-06) ----
  Future<Rehearsal> createRehearsal(
    String groupId, {
    required String title,
    required DateTime startsAt,
    String? location,
    String? setlistId,
    String? notes,
  }) async {
    final data = await _api.post('/api/groups/$groupId/rehearsals', {
      'title': title,
      'starts_at': startsAt.toUtc().toIso8601String(),
      if (location != null && location.isNotEmpty) 'location': location,
      if (setlistId != null) 'setlist_id': setlistId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return Rehearsal.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Rehearsal>> fetchRehearsals(String groupId) async {
    final data = await _api.get('/api/groups/$groupId/rehearsals') as List;
    return data.map((e) => Rehearsal.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Rehearsal> getRehearsal(String id) async {
    final data = await _api.get('/api/rehearsals/$id');
    return Rehearsal.fromJson(data as Map<String, dynamic>);
  }

  Future<Rehearsal> setAttendance(String rehearsalId, String status) async {
    final data = await _api.put('/api/rehearsals/$rehearsalId/attendance', {'status': status});
    return Rehearsal.fromJson(data as Map<String, dynamic>);
  }
}
