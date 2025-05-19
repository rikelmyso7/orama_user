class ChecklistItemModel {
  final String id;
  final String title;
  final String description;
  bool completed;
  String? imagePath;

  ChecklistItemModel({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'completed': completed,
        'imagePath': imagePath,
      };

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) => ChecklistItemModel(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        completed: json['completed'],
        imagePath: json['imagePath'],
      );
}
