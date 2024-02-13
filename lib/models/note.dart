class Note {
  final int id;
  final String title;
  final String description;

  Note({required this.id, required this.title, required this.description});

  factory Note.fromSqfliteDatabase(Map<String, dynamic> map) => Note(
        id: map['id']?.toInt() ?? 0,
        title: map['title'],
        description: map['description'],
      );

  Note.fromMap(Map<String, dynamic> item)
      : id = item['id'],
        title = item['title'],
        description = item['description'];

  Map<String, Object> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
