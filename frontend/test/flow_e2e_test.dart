// Test E2E del flujo principal de XANEE (HU-01..HU-06) sobre la UI real.
//
// Usa dobles de prueba (fakes) para el repositorio y la autenticación, de modo
// que recorre las pantallas reales (login → grupos → detalle → ensayo → asistencia)
// sin depender de Supabase ni de un backend en marcha. Ejecutable con:
//   flutter test integration_test/app_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:xanee_frontend/core/api_client.dart';
import 'package:xanee_frontend/core/app_router.dart';
import 'package:xanee_frontend/core/repository.dart';
import 'package:xanee_frontend/features/auth/auth_service.dart';
import 'package:xanee_frontend/features/groups/group_models.dart';
import 'package:xanee_frontend/features/rehearsals/rehearsal_models.dart';
import 'package:xanee_frontend/features/scores/score_models.dart';
import 'package:xanee_frontend/features/setlists/setlist_models.dart';

/// Repositorio en memoria que simula el backend para el test de flujo.
class FakeRepository extends DataRepository {
  FakeRepository() : super(ApiClient(AuthService()));

  final _score = Score(
    id: 's1',
    title: 'Marcha de Ejemplo',
    format: 'musicxml',
    fileUrl: 'https://example/scores/marcha.musicxml',
    composer: 'Anónimo',
  );

  String _myAttendance = '';
  int _confirmed = 0;

  @override
  Future<List<Group>> fetchGroups() async =>
      [Group(id: 'g1', name: 'Banda Municipal', type: 'banda', myRole: 'admin')];

  @override
  Future<Group> getGroup(String id) async =>
      Group(id: 'g1', name: 'Banda Municipal', type: 'banda', myRole: 'admin');

  @override
  Future<List<Score>> fetchScores(String groupId) async => [_score];

  @override
  Future<List<Setlist>> fetchSetlists(String groupId) async =>
      [Setlist(id: 'sl1', name: 'Concierto de Primavera', items: [
        SetlistItem(id: 'i1', scoreId: 's1', position: 0),
      ])];

  @override
  Future<Setlist> getSetlist(String id) async =>
      Setlist(id: 'sl1', name: 'Concierto de Primavera', items: [
        SetlistItem(id: 'i1', scoreId: 's1', position: 0),
      ]);

  @override
  Future<List<Rehearsal>> fetchRehearsals(String groupId) async => [
        Rehearsal(
          id: 'r1',
          groupId: 'g1',
          title: 'Ensayo general',
          startsAt: DateTime(2026, 8, 10, 18),
          location: 'Auditorio',
          summary: AttendanceSummary(pending: 2, confirmed: _confirmed),
          myAttendance: _myAttendance.isEmpty ? null : _myAttendance,
        )
      ];

  @override
  Future<Rehearsal> getRehearsal(String id) async => Rehearsal(
        id: 'r1',
        groupId: 'g1',
        title: 'Ensayo general',
        startsAt: DateTime(2026, 8, 10, 18),
        location: 'Auditorio',
        setlist: Setlist(id: 'sl1', name: 'Concierto de Primavera', items: [
          SetlistItem(id: 'i1', scoreId: 's1', position: 0),
        ]),
        summary: AttendanceSummary(pending: 2 - _confirmed, confirmed: _confirmed),
        myAttendance: _myAttendance.isEmpty ? null : _myAttendance,
      );

  @override
  Future<Rehearsal> setAttendance(String rehearsalId, String status) async {
    _myAttendance = status;
    _confirmed = status == 'confirmed' ? 1 : 0;
    return getRehearsal(rehearsalId);
  }
}

Widget _harness(AuthService auth, DataRepository repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth),
      Provider<DataRepository>.value(value: repo),
    ],
    child: MaterialApp.router(routerConfig: buildRouter(auth)),
  );
}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  testWidgets('Flujo E2E: login → grupo → ensayo → confirmar asistencia',
      (tester) async {
    final auth = AuthService(); // modo demo (sin Supabase)
    final repo = FakeRepository();
    await tester.pumpWidget(_harness(auth, repo));
    await tester.pumpAndSettle();

    // 1) Estamos en login. Introducimos credenciales y entramos (HU-01).
    expect(find.text('Inicia sesión'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('email_field')), 'director@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'secret1');
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pumpAndSettle();

    // 2) Listado de grupos (HU-02): vemos nuestra banda.
    expect(find.text('Mis grupos'), findsOneWidget);
    expect(find.text('Banda Municipal'), findsOneWidget);

    // 3) Entramos al grupo y navegamos a la pestaña Ensayos.
    await tester.tap(find.text('Banda Municipal'));
    await tester.pumpAndSettle();
    expect(find.text('Partituras'), findsOneWidget);
    await tester.tap(find.text('Ensayos'));
    await tester.pumpAndSettle();
    expect(find.text('Ensayo general'), findsOneWidget);

    // 4) Abrimos el detalle del ensayo (HU-05): vemos su repertorio.
    await tester.tap(find.text('Ensayo general'));
    await tester.pumpAndSettle();
    expect(find.text('Repertorio'), findsOneWidget);
    expect(find.text('Marcha de Ejemplo'), findsOneWidget);

    // 5) Confirmamos asistencia (HU-06) y comprobamos el resumen.
    await tester.tap(find.text('Confirmo'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmados: 1'), findsOneWidget);
  });
}
