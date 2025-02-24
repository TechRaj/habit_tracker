class Habit {
  String name;
  bool isCompleted; // For boolean habits (yes/no)
  int progress; // For progress-based habits
  int goal; // Goal (e.g., 30 minutes, 10k steps)
  
  Habit({
    required this.name,
    this.isCompleted = false,
    this.progress = 0,
    required this.goal,
  });

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'progress': progress,
      'goal': goal,
    };
  }

  // Convert from JSON (loading from storage)
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      isCompleted: json['isCompleted'] ?? false,
      progress: json['progress'] ?? 0,
      goal: json['goal'] ?? 0,
    );
  }
}