class TasbeehCounter {
  final int? id; // null until the row is saved in the DB
  final String name;
  final int count;
  final int target;
  final String createdAt;

  TasbeehCounter({
    this.id,
    required this.name,
    this.count = 0,
    this.target = 33,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  // Object -> Map (for inserting/updating in SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'target': target,
      'created_at': createdAt,
    };
  }

  // Map -> Object (for reading rows from SQLite)
  factory TasbeehCounter.fromMap(Map<String, dynamic> map) {
    return TasbeehCounter(
      id: map['id'] as int?,
      name: map['name'] as String,
      count: map['count'] as int,
      target: map['target'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  // Makes a modified copy (fields are final, so we can't edit in place)
  TasbeehCounter copyWith({int? id, String? name, int? count, int? target}) {
    return TasbeehCounter(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      target: target ?? this.target,
      createdAt: createdAt,
    );
  }
}