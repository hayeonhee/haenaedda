class Goal {
  final String id;
  String name;

  Goal(this.id, this.name);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      json['id'] as String,
      json['name'] as String,
    );
  }
}
