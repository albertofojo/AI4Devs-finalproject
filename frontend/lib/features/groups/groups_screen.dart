import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/repository.dart';
import '../auth/auth_service.dart';
import 'group_models.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late Future<List<Group>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<DataRepository>().fetchGroups();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis grupos'),
        actions: [
          IconButton(
            tooltip: 'Aceptar invitación',
            icon: const Icon(Icons.mail_outline),
            onPressed: _showAcceptInvitation,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthService>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGroup,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo grupo'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Group>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorView(message: '${snap.error}', onRetry: _refresh);
            }
            final groups = snap.data ?? [];
            if (groups.isEmpty) {
              return const _EmptyView();
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final g = groups[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(g.name.characters.first)),
                    title: Text(g.name),
                    subtitle: Text('${g.type} · ${g.isAdmin ? "Administrador" : "Miembro"}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/groups/${g.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateGroup() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateGroupDialog(),
    );
    if (created == true) setState(_reload);
  }

  Future<void> _showAcceptInvitation() async {
    final controller = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aceptar invitación'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Token de invitación',
            hintText: 'Pega aquí el token que te compartieron',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              try {
                await context
                    .read<DataRepository>()
                    .acceptInvitation(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx, true);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx)
                      .showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (accepted == true) setState(_reload);
  }
}

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog();

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  String _type = 'banda';
  bool _saving = false;
  String? _error;

  static const _types = ['banda', 'orquesta', 'tradicional', 'escuela'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo grupo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            key: const Key('group_name_field'),
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: _types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? 'banda'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        FilledButton(
          key: const Key('group_create_button'),
          onPressed: _saving ? null : _save,
          child: const Text('Crear'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context
          .read<DataRepository>()
          .createGroup(_name.text.trim(), _type, _desc.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = '$e';
        _saving = false;
      });
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Center(child: Text('Aún no perteneces a ningún grupo')),
        SizedBox(height: 4),
        Center(child: Text('Crea uno nuevo o acepta una invitación')),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
        const SizedBox(height: 12),
        Center(child: Text(message, textAlign: TextAlign.center)),
        const SizedBox(height: 12),
        Center(child: FilledButton(onPressed: onRetry, child: const Text('Reintentar'))),
      ],
    );
  }
}
