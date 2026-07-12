import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/repository.dart';
import '../scores/score_models.dart';
import 'setlist_models.dart';

/// Hoja para gestionar un setlist: ver sus partituras en orden y añadir nuevas
/// desde el repertorio del grupo (HU-05).
class SetlistManageSheet extends StatefulWidget {
  const SetlistManageSheet({
    super.key,
    required this.groupId,
    required this.setlistId,
  });
  final String groupId;
  final String setlistId;

  @override
  State<SetlistManageSheet> createState() => _SetlistManageSheetState();
}

class _SetlistManageSheetState extends State<SetlistManageSheet> {
  DataRepository get _repo => context.read<DataRepository>();
  Setlist? _setlist;
  List<Score> _scores = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final setlist = await _repo.getSetlist(widget.setlistId);
      final scores = await _repo.fetchScores(widget.groupId);
      if (!mounted) return;
      setState(() {
        _setlist = setlist;
        _scores = scores;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Score? _scoreById(String id) {
    for (final s in _scores) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final setlist = _setlist;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: setlist == null
          ? SizedBox(
              height: 200,
              child: Center(
                child: _error != null
                    ? Text(_error!)
                    : const CircularProgressIndicator(),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(setlist.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (setlist.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Este setlist aún no tiene partituras.'),
                  )
                else
                  ...setlist.items.map((item) {
                    final score = _scoreById(item.scoreId);
                    return ListTile(
                      leading: CircleAvatar(child: Text('${item.position + 1}')),
                      title: Text(score?.title ?? 'Partitura'),
                      subtitle: item.notes != null ? Text(item.notes!) : null,
                      trailing: score != null && score.isMusicXml
                          ? IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => context.push('/viewer', extra: {
                                'title': score.title,
                                'url': score.fileUrl,
                                'format': score.format,
                              }),
                            )
                          : null,
                    );
                  }),
                const Divider(),
                FilledButton.icon(
                  onPressed: _scores.isEmpty ? null : _addScore,
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir partitura'),
                ),
                if (_scores.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Sube partituras al grupo para poder añadirlas.'),
                  ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }

  Future<void> _addScore() async {
    final chosen = await showDialog<Score>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Elegir partitura'),
        children: [
          for (final s in _scores)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, s),
              child: Text(s.title),
            ),
        ],
      ),
    );
    if (chosen == null) return;
    try {
      await _repo.addSetlistItem(widget.setlistId, chosen.id, null);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
