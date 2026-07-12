class SetlistItem {
  SetlistItem({
    required this.id,
    required this.scoreId,
    required this.position,
    this.notes,
  });

  final String id;
  final String scoreId;
  final int position;
  final String? notes;

  factory SetlistItem.fromJson(Map<String, dynamic> j) => SetlistItem(
        id: j['id'] as String,
        scoreId: j['score_id'] as String,
        position: j['position'] as int,
        notes: j['notes'] as String?,
      );
}

class Setlist {
  Setlist({
    required this.id,
    required this.name,
    this.description,
    this.items = const [],
  });

  final String id;
  final String name;
  final String? description;
  final List<SetlistItem> items;

  factory Setlist.fromJson(Map<String, dynamic> j) => Setlist(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String?,
        items: ((j['items'] as List?) ?? [])
            .map((e) => SetlistItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
