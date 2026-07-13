import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/repository.dart';
import '../scores/score_models.dart';
import 'rehearsal_models.dart';

/// Detalle de un ensayo: repertorio (setlist) y control de asistencia (HU-06).
class RehearsalDetailScreen extends StatefulWidget {
  const RehearsalDetailScreen({super.key, required this.rehearsalId});
  final String rehearsalId;

  @override
  State<RehearsalDetailScreen> createState() => _RehearsalDetailScreenState();
}

class _RehearsalDetailScreenState extends State<RehearsalDetailScreen> {
  DataRepository get _repo => context.read<DataRepository>();
  Rehearsal? _rehearsal;
  Map<String, Score> _scoresById = {};
  String? _error;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await _repo.getRehearsal(widget.rehearsalId);
      final scores = await _repo.fetchScores(r.groupId);
      if (!mounted) return;
      setState(() {
        _rehearsal = r;
        _scoresById = {for (final s in scores) s.id: s};
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _setAttendance(String status) async {
    setState(() => _updating = true);
    try {
      final r = await _repo.setAttendance(widget.rehearsalId, status);
      if (mounted) setState(() => _rehearsal = r);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _rehearsal;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(r?.title ?? 'Ensayo'),
      ),
      body: r == null
          ? Center(
              child: _error != null
                  ? Text(_error!)
                  : const CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InfoCard(rehearsal: r),
                const SizedBox(height: 16),
                Text('Mi asistencia', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _AttendanceSelector(
                  value: r.myAttendance,
                  enabled: !_updating,
                  onChanged: _setAttendance,
                ),
                const SizedBox(height: 8),
                _SummaryRow(summary: r.summary),
                const SizedBox(height: 24),
                Text('Repertorio', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (r.setlist == null || r.setlist!.items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Este ensayo no tiene setlist asociado.'),
                    ),
                  )
                else
                  ...r.setlist!.items.map((item) {
                    final score = _scoresById[item.scoreId];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${item.position + 1}')),
                        title: Text(score?.title ?? 'Partitura'),
                        subtitle: Text([
                          if (score?.composer != null) score!.composer!,
                          if (item.notes != null) item.notes!,
                        ].join(' · ')),
                        trailing: score != null
                            ? IconButton(
                                icon: const Icon(Icons.open_in_new),
                                tooltip: 'Abrir partitura',
                                onPressed: () => context.push('/viewer', extra: {
                                  'title': score.title,
                                  'url': score.fileUrl,
                                  'format': score.format,
                                }),
                              )
                            : null,
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rehearsal});
  final Rehearsal rehearsal;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEEE d MMMM yyyy · HH:mm', 'es');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.schedule, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(fmt.format(rehearsal.startsAt.toLocal()))),
            ]),
            if (rehearsal.location != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(rehearsal.location!)),
              ]),
            ],
            if (rehearsal.notes != null) ...[
              const SizedBox(height: 8),
              Text(rehearsal.notes!,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _AttendanceSelector extends StatelessWidget {
  const _AttendanceSelector({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final String? value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'confirmed', label: Text('Confirmo'), icon: Icon(Icons.check)),
        ButtonSegment(value: 'maybe', label: Text('En duda'), icon: Icon(Icons.help_outline)),
        ButtonSegment(value: 'absent', label: Text('No voy'), icon: Icon(Icons.close)),
      ],
      selected: value == null ? <String>{} : {value!},
      emptySelectionAllowed: true,
      onSelectionChanged:
          enabled ? (sel) => sel.isNotEmpty ? onChanged(sel.first) : null : null,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});
  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int n, Color c) => Chip(
          avatar: CircleAvatar(backgroundColor: c, radius: 10),
          label: Text('$label: $n'),
        );
    return Wrap(
      spacing: 8,
      children: [
        chip('Confirmados', summary.confirmed, Colors.green),
        chip('En duda', summary.maybe, Colors.orange),
        chip('Ausentes', summary.absent, Colors.red),
        chip('Pendientes', summary.pending, Colors.grey),
      ],
    );
  }
}
