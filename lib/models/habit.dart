class Habit {
  String name;
  bool isCompleted; // For boolean habits (yes/no)
  int progress; // For progress-based habits
  int goal; // Goal (e.g., 30 minutes, 10k steps)
  int streak; // Streak counter
  List<String> history; 
  
  Habit({
    required this.name,
    this.isCompleted = false,
    this.progress = 0,
    required this.goal,
    this.streak = 0, // Default streak is 0
    List<String>? history, // ✅ Initialize with optional history
  }) : history = history ?? List.filled(7, '⚪'); // Default last 7 days as ⚪


  // Convert to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'progress': progress,
      'goal': goal,
      'streak': streak,
      'history': history,
    };
  }

  // Convert from JSON (loading from storage)
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      isCompleted: json['isCompleted'] ?? false,
      progress: json['progress'] ?? 0,
      goal: (json['goal'] != null && json['goal'] > 0) ? json['goal'] : 1,
      streak: json.containsKey('streak') ? json['streak'] : 0,
      history: List<String>.from(json['history'] ?? List.filled(7, '⚪')),
    );
  }
}