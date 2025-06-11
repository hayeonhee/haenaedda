class Goal {
  final String id;
  int order;
  String title;

  Goal(this.id, this.order, this.title);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'title': title,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      json['id'] as String,
      json['order'] as int,
      json['title'] as String,
    );
  }
}
