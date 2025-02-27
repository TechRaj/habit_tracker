import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Habit> habits = [];
  int completedToday = 0;
  int totalHabits = 0;
  int totalStreaks = 0;
  Habit? mostConsistentHabit;
  int weeklyCompletionRate = 0; // 📊 Weekly Completion Rate
  int consistencyScore = 0; // 📅 Habit Consistency Score
  String emojiGraph = "📅 Past 7 Days: ⚪⚪⚪⚪⚪⚪⚪"; // Default empty graph
  String weeklyProgressGraph = "⚪⚪⚪⚪⚪⚪⚪"; // Default empty graph

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }
  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> keys = ['power_habits', 'limit_habits']; // 🚀🔒
    List<Habit> powerHabits = []; // 🚀 Power Habits
    List<Habit> limitHabits = []; // 🔒 Limit Habits

    for (String key in keys) {
      String? savedData = prefs.getString(key);
      if (savedData != null) {
        List<Habit> habitsList = (json.decode(savedData) as List)
            .map((item) => Habit.fromJson(item))
            .toList();

        for (var habit in habitsList) {
          if (habit.goal > 0) {
            powerHabits.add(habit);
          } else {
            limitHabits.add(habit);
          }
        }
      }
    }

    // ✅ Combine all habits into one list
    List<Habit> allHabits = [...powerHabits, ...limitHabits];

    // ✅ Calculate streaks & best habit
    int completed = allHabits.where((h) => h.isCompleted).length;
    int streaks = allHabits.fold(0, (sum, h) => sum + h.streak);
    Habit? topHabit = allHabits.isNotEmpty
        ? allHabits.reduce((a, b) => a.streak > b.streak ? a : b)
        : null;

    // ✅ Track Last 7 Days for Emoji Graph
    List<String> weeklyHistory =
        prefs.getStringList('weeklyHistory')?.toList() ?? List.filled(7, '⚪').toList();
    if (completed > 0) {
      weeklyHistory.add('🟢'); // Mark as completed
    } else {
      weeklyHistory.add('⚪'); // Mark as missed
    }
    if (weeklyHistory.length > 7) weeklyHistory.removeAt(0); // Keep last 7 days only
    prefs.setStringList('weeklyHistory', weeklyHistory);

    // ✅ Ensure weeklyProgressGraph updates AFTER saving history
    this.weeklyProgressGraph = weeklyHistory.map((day) => day == '🟢' ? '🔵' : '⚪').join('');

    // ✅ Weekly Completion Rate
    int weeklyCompleted = weeklyHistory.where((day) => day == '🟢').length;
    int weeklyCompletionRate = ((weeklyCompleted / 7) * 100).toInt();

    // ✅ Habit Consistency Score
    int consistencyScore = _calculateConsistency(allHabits);

    // ✅ Update UI
    setState(() {
      habits = allHabits;
      completedToday = completed;
      totalHabits = allHabits.length;
      totalStreaks = streaks;
      mostConsistentHabit = topHabit;
      this.weeklyCompletionRate = weeklyCompletionRate;
      this.consistencyScore = consistencyScore;
      this.emojiGraph = "📅 Past 7 Days: " + weeklyHistory.join(' '); // 🔥 Assign to class variable
    });
  }

  int _calculateConsistency(List<Habit> habits) {
    if (habits.isEmpty) return 0;

    int totalDaysTracked = 7; // Last 7 days
    int totalCompletions = habits.fold(0, (sum, h) => sum + (h.streak > 0 ? 1 : 0));

    return ((totalCompletions / (habits.length * totalDaysTracked)) * 100).toInt();
  }

Widget _buildStatsSection() {
  return Card(
    margin: EdgeInsets.all(12),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📊 Daily Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: totalHabits > 0 ? completedToday / totalHabits : 0,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
            minHeight: 10,
          ),
          SizedBox(height: 8),
          Text("Completed: $completedToday / $totalHabits habits"),
          SizedBox(height: 12),

          Text("🔥 Longest Streak", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Total Streaks: $totalStreaks days"),
          
          SizedBox(height: 12),
          Text("🏆 Best Performing Habit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          if (mostConsistentHabit != null && mostConsistentHabit!.streak > 0) ...[
            Text("${mostConsistentHabit!.name} - ${mostConsistentHabit!.streak} days 🔥", style: TextStyle(fontSize: 16)),
          ] else ...[
            Text("🏆 Get started! Complete a habit today.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],  

          SizedBox(height: 12),
          Text(emojiGraph, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📊 Weekly Completion", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(weeklyProgressGraph, style: TextStyle(fontSize: 20)), // 🔥 Display emoji bar graph
              Text("$weeklyCompletionRate% completed", style: TextStyle(fontSize: 16)),
              if (weeklyCompletionRate < 50) // 🔥 Suggest improvement if too low
                Text("⚠️ Try to complete more habits this week!", style: TextStyle(fontSize: 14, color: Colors.red)),
            ],
          ),

          SizedBox(height: 12),
          Text("📅 Habit Consistency: $consistencyScore%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🏆 Main Dashboard")),
      body: Column(
        children: [
          _buildStatsSection(),
          Expanded(
            child: Center(
              child: Text(
                "More Features Coming Soon!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}