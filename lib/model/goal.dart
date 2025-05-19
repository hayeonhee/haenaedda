class Goal {
  final String id;
  // TODO: Add order property
  // int order;
  String title;

  Goal(this.id, this.title);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      json['id'] as String,
      json['title'] as String,
    );
  }
}
