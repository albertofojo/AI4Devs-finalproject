// Genera capturas reales de cada pantalla de XANEE para la documentación de la
// entrega. Renderiza la app real con datos de ejemplo (fakes) y navega por el
// flujo, exportando PNGs a docs/screenshots/ con `flutter test --update-goldens`.
//
//   flutter test --update-goldens test/screenshots_test.dart
//
// Etiquetado como `golden`: se excluye del CI (el render varía por plataforma) y
// solo se ejecuta manualmente para regenerar las capturas.
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:xanee_frontend/core/api_client.dart';
import 'package:xanee_frontend/core/app_router.dart';
import 'package:xanee_frontend/core/repository.dart';
import 'package:xanee_frontend/core/theme.dart';
import 'package:xanee_frontend/features/auth/auth_service.dart';
import 'package:xanee_frontend/features/groups/group_models.dart';
import 'package:xanee_frontend/features/rehearsals/rehearsal_models.dart';
import 'package:xanee_frontend/features/scores/score_models.dart';
import 'package:xanee_frontend/features/setlists/setlist_models.dart';

class DemoRepository extends DataRepository {
  DemoRepository() : super(ApiClient(AuthService()));

  final _scores = [
    Score(id: 's1', title: 'Marcha de Ejemplo', format: 'musicxml', fileUrl: 'u1', composer: 'A. Anónimo', keySignature: 'Bb'),
    Score(id: 's2', title: 'Preludio en Re', format: 'musicxml', fileUrl: 'u2', composer: 'J. S. Bach', keySignature: 'D'),
    Score(id: 's3', title: 'Himno del Grupo', format: 'pdf', fileUrl: 'u3', composer: 'Tradicional'),
  ];
  String _att = '';
  int _confirmed = 3;

  @override
  Future<List<Group>> fetchGroups() async => [
        Group(id: 'g1', name: 'Banda Municipal de Ejemplo', type: 'banda', description: 'Viento y percusión', myRole: 'admin'),
        Group(id: 'g2', name: 'Orquesta de Cámara', type: 'orquesta', myRole: 'member'),
      ];

  @override
  Future<Group> getGroup(String id) async =>
      Group(id: 'g1', name: 'Banda Municipal de Ejemplo', type: 'banda', description: 'Viento y percusión', myRole: 'admin');

  @override
  Future<List<Score>> fetchScores(String groupId) async => _scores;

  @override
  Future<List<Setlist>> fetchSetlists(String groupId) async => [
        Setlist(id: 'sl1', name: 'Concierto de Primavera', items: [
          SetlistItem(id: 'i1', scoreId: 's1', position: 0),
          SetlistItem(id: 'i2', scoreId: 's2', position: 1),
        ]),
        Setlist(id: 'sl2', name: 'Repertorio de Calle', items: [SetlistItem(id: 'i3', scoreId: 's3', position: 0)]),
      ];

  @override
  Future<Setlist> getSetlist(String id) async => Setlist(id: 'sl1', name: 'Concierto de Primavera', items: [
        SetlistItem(id: 'i1', scoreId: 's1', position: 0, notes: 'Repasar dinámicas'),
        SetlistItem(id: 'i2', scoreId: 's2', position: 1),
      ]);

  @override
  Future<List<Rehearsal>> fetchRehearsals(String groupId) async => [
        Rehearsal(id: 'r1', groupId: 'g1', title: 'Ensayo general', startsAt: DateTime(2026, 8, 10, 18), location: 'Auditorio Sala 2',
            summary: AttendanceSummary(confirmed: 3, maybe: 1, absent: 1, pending: 2)),
        Rehearsal(id: 'r2', groupId: 'g1', title: 'Ensayo de cuerda', startsAt: DateTime(2026, 8, 14, 19), location: 'Local de ensayo',
            summary: AttendanceSummary(confirmed: 5, pending: 2)),
      ];

  @override
  Future<Rehearsal> getRehearsal(String id) async => Rehearsal(
        id: 'r1', groupId: 'g1', title: 'Ensayo general', startsAt: DateTime(2026, 8, 10, 18), location: 'Auditorio Sala 2',
        notes: 'Repasar el 2º movimiento',
        setlist: Setlist(id: 'sl1', name: 'Concierto de Primavera', items: [
          SetlistItem(id: 'i1', scoreId: 's1', position: 0, notes: 'Repasar dinámicas'),
          SetlistItem(id: 'i2', scoreId: 's2', position: 1),
        ]),
        summary: AttendanceSummary(confirmed: _confirmed, maybe: 1, absent: 1, pending: 2 - (_att == 'confirmed' ? 1 : 0)),
        myAttendance: _att.isEmpty ? null : _att,
      );

  @override
  Future<Rehearsal> setAttendance(String rehearsalId, String status) async {
    _att = status;
    _confirmed = 3 + (status == 'confirmed' ? 1 : 0);
    return getRehearsal(rehearsalId);
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../../docs/screenshots/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting('es');
  });

  testWidgets('capturas del flujo XANEE', (tester) async {
    tester.view.physicalSize = const Size(1300, 860);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthService();
    final repo = DemoRepository();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        Provider<DataRepository>.value(value: repo),
      ],
      child: MaterialApp.router(theme: AppTheme.light, debugShowCheckedModeBanner: false, routerConfig: buildRouter(auth)),
    ));
    await tester.pumpAndSettle();

    // 01 — Login
    await _shot(tester, '01_login');

    // Iniciar sesión
    await tester.enterText(find.byKey(const Key('email_field')), 'director@ejemplo.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'secreto123');
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pumpAndSettle();

    // 02 — Mis grupos
    await _shot(tester, '02_grupos');

    // Entrar al grupo → pestaña Partituras
    await tester.tap(find.text('Banda Municipal de Ejemplo'));
    await tester.pumpAndSettle();
    await _shot(tester, '03_partituras');

    // Pestaña Setlists
    await tester.tap(find.text('Setlists'));
    await tester.pumpAndSettle();
    await _shot(tester, '04_setlists');

    // Pestaña Ensayos
    await tester.tap(find.text('Ensayos'));
    await tester.pumpAndSettle();
    await _shot(tester, '05_ensayos');

    // Detalle de ensayo
    await tester.tap(find.text('Ensayo general'));
    await tester.pumpAndSettle();
    await _shot(tester, '06_ensayo_detalle');

    // Confirmar asistencia
    await tester.tap(find.text('Confirmo'));
    await tester.pumpAndSettle();
    await _shot(tester, '07_asistencia_confirmada');
  });
}
