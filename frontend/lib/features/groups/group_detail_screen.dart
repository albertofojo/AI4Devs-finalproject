import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/repository.dart';
import '../rehearsals/rehearsal_models.dart';
import '../scores/score_models.dart';
import '../scores/upload_score_dialog.dart';
import '../setlists/setlist_models.dart';
import '../setlists/setlist_manage_sheet.dart';
import 'group_models.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final String groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  DataRepository get _repo => context.read<DataRepository>();
  late Future<Group> _group;

  @override
  void initState() {
    super.initState();
    _group = _repo.getGroup(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Group>(
      future: _group,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: snap.hasError
                ? Center(child: Text('${snap.error}'))
                : const Center(child: CircularProgressIndicator()),
          );
        }
        final group = snap.data!;
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
              title: Text(group.name),
              actions: [
                if (group.isAdmin)
                  IconButton(
                    tooltip: 'Invitar músico',
                    icon: const Icon(Icons.person_add_alt),
                    onPressed: () => _invite(group),
                  ),
              ],
              bottom: const TabBar(tabs: [
                Tab(text: 'Partituras', icon: Icon(Icons.library_music_outlined)),
                Tab(text: 'Setlists', icon: Icon(Icons.queue_music_outlined)),
                Tab(text: 'Ensayos', icon: Icon(Icons.event_outlined)),
              ]),
            ),
            body: TabBarView(children: [
              _ScoresTab(groupId: group.id),
              _SetlistsTab(groupId: group.id),
              _RehearsalsTab(group: group),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _invite(Group group) async {
    final email = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invitar músico'),
        content: TextField(
          controller: email,
          decoration: const InputDecoration(labelText: 'Email del músico'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                final token = await _repo.createInvitation(group.id, email.text.trim());
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _showToken(token);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            child: const Text('Generar invitación'),
          ),
        ],
      ),
    );
  }

  void _showToken(String token) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invitación creada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Comparte este token con el músico para que se una:'),
            const SizedBox(height: 12),
            SelectableText(token, style: const TextStyle(fontFamily: 'monospace')),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hecho')),
        ],
      ),
    );
  }
}

// ---------------- Pestaña Partituras ----------------
class _ScoresTab extends StatefulWidget {
  const _ScoresTab({required this.groupId});
  final String groupId;

  @override
  State<_ScoresTab> createState() => _ScoresTabState();
}

class _ScoresTabState extends State<_ScoresTab> {
  late Future<List<Score>> _future;
  DataRepository get _repo => context.read<DataRepository>();

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchScores(widget.groupId);
  }

  void _reload() => setState(() => _future = _repo.fetchScores(widget.groupId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => UploadScoreDialog(groupId: widget.groupId),
          );
          if (ok == true) _reload();
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Subir partitura'),
      ),
      body: FutureBuilder<List<Score>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return snap.hasError
                ? Center(child: Text('${snap.error}'))
                : const Center(child: CircularProgressIndicator());
          }
          final scores = snap.data!;
          if (scores.isEmpty) {
            return const Center(child: Text('Aún no hay partituras. Sube la primera.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final s in scores)
                Card(
                  child: ListTile(
                    leading: Icon(
                        s.isMusicXml ? Icons.music_note : Icons.picture_as_pdf),
                    title: Text(s.title),
                    subtitle: Text([
                      if (s.composer != null) s.composer!,
                      s.format.toUpperCase(),
                      if (s.keySignature != null) 'Ton. ${s.keySignature}',
                    ].join(' · ')),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => context.push('/viewer', extra: {
                      'title': s.title,
                      'url': s.fileUrl,
                      'format': s.format,
                    }),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------- Pestaña Setlists ----------------
class _SetlistsTab extends StatefulWidget {
  const _SetlistsTab({required this.groupId});
  final String groupId;

  @override
  State<_SetlistsTab> createState() => _SetlistsTabState();
}

class _SetlistsTabState extends State<_SetlistsTab> {
  late Future<List<Setlist>> _future;
  DataRepository get _repo => context.read<DataRepository>();

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchSetlists(widget.groupId);
  }

  void _reload() => setState(() => _future = _repo.fetchSetlists(widget.groupId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createSetlist,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo setlist'),
      ),
      body: FutureBuilder<List<Setlist>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return snap.hasError
                ? Center(child: Text('${snap.error}'))
                : const Center(child: CircularProgressIndicator());
          }
          final setlists = snap.data!;
          if (setlists.isEmpty) {
            return const Center(child: Text('Crea un setlist para tu próximo ensayo.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final sl in setlists)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.queue_music),
                    title: Text(sl.name),
                    subtitle: Text('${sl.items.length} partitura(s)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => SetlistManageSheet(
                          groupId: widget.groupId,
                          setlistId: sl.id,
                        ),
                      );
                      _reload();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createSetlist() async {
    final name = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo setlist'),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Nombre del setlist'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              await _repo.createSetlist(widget.groupId, name.text.trim(), null);
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (ok == true) _reload();
  }
}

// ---------------- Pestaña Ensayos ----------------
class _RehearsalsTab extends StatefulWidget {
  const _RehearsalsTab({required this.group});
  final Group group;

  @override
  State<_RehearsalsTab> createState() => _RehearsalsTabState();
}

class _RehearsalsTabState extends State<_RehearsalsTab> {
  late Future<List<Rehearsal>> _future;
  DataRepository get _repo => context.read<DataRepository>();
  final _dateFmt = DateFormat('EEE d MMM · HH:mm', 'es');

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchRehearsals(widget.group.id);
  }

  void _reload() => setState(() => _future = _repo.fetchRehearsals(widget.group.id));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.group.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _scheduleRehearsal,
              icon: const Icon(Icons.event_available),
              label: const Text('Programar ensayo'),
            )
          : null,
      body: FutureBuilder<List<Rehearsal>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return snap.hasError
                ? Center(child: Text('${snap.error}'))
                : const Center(child: CircularProgressIndicator());
          }
          final rehearsals = snap.data!;
          if (rehearsals.isEmpty) {
            return const Center(child: Text('No hay ensayos programados.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final r in rehearsals)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(r.title),
                    subtitle: Text([
                      _dateFmt.format(r.startsAt.toLocal()),
                      if (r.location != null) r.location!,
                      '✓ ${r.summary.confirmed}  ? ${r.summary.maybe}  ✗ ${r.summary.absent}',
                    ].join('\n')),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await context.push('/rehearsals/${r.id}');
                      _reload();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _scheduleRehearsal() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ScheduleRehearsalDialog(groupId: widget.group.id),
    );
    if (ok == true) _reload();
  }
}

class _ScheduleRehearsalDialog extends StatefulWidget {
  const _ScheduleRehearsalDialog({required this.groupId});
  final String groupId;

  @override
  State<_ScheduleRehearsalDialog> createState() => _ScheduleRehearsalDialogState();
}

class _ScheduleRehearsalDialogState extends State<_ScheduleRehearsalDialog> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String? _setlistId;
  List<Setlist> _setlists = [];
  bool _saving = false;
  String? _error;

  DataRepository get _repo => context.read<DataRepository>();

  @override
  void initState() {
    super.initState();
    _repo.fetchSetlists(widget.groupId).then((s) {
      if (mounted) setState(() => _setlists = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy · HH:mm', 'es');
    return AlertDialog(
      title: const Text('Programar ensayo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              key: const Key('rehearsal_title_field'),
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Lugar (opcional)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha y hora'),
              subtitle: Text(fmt.format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            DropdownButtonFormField<String?>(
              initialValue: _setlistId,
              decoration: const InputDecoration(labelText: 'Setlist (opcional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('— Sin setlist —')),
                for (final s in _setlists)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => _setlistId = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(
          key: const Key('rehearsal_save_button'),
          onPressed: _saving ? null : _save,
          child: const Text('Programar'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (!mounted) return;
    setState(() {
      _date = DateTime(d.year, d.month, d.day, t?.hour ?? 18, t?.minute ?? 0);
    });
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'El título es obligatorio');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repo.createRehearsal(
        widget.groupId,
        title: _title.text.trim(),
        startsAt: _date,
        location: _location.text.trim(),
        setlistId: _setlistId,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = '$e';
        _saving = false;
      });
    }
  }
}
