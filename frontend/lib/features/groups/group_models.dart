class Group {
  Group({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.myRole,
  });

  final String id;
  final String name;
  final String type;
  final String? description;
  final String? myRole;

  bool get isAdmin => myRole == 'admin';

  factory Group.fromJson(Map<String, dynamic> j) => Group(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String,
        description: j['description'] as String?,
        myRole: j['my_role'] as String?,
      );
}
