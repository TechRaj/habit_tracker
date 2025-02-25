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

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Load habits from all categories
    List<String> keys = ['health_habits', 'productivity_habits', 'lifestyle_habits'];
    List<Habit> allHabits = [];

    for (String key in keys) {
      String? savedData = prefs.getString(key);
      if (savedData != null) {
        List<Habit> habitsList = (json.decode(savedData) as List)
            .map((item) => Habit.fromJson(item))
            .toList();
        allHabits.addAll(habitsList);
      }
    }

    // Calculate stats
    int completed = allHabits.where((h) => h.isCompleted).length;
    int streaks = allHabits.fold(0, (sum, h) => sum + h.streak);
    Habit? topHabit = allHabits.isNotEmpty
        ? allHabits.reduce((a, b) => a.streak > b.streak ? a : b)
        : null;

    setState(() {
      habits = allHabits;
      completedToday = completed;
      totalHabits = allHabits.length;
      totalStreaks = streaks;
      mostConsistentHabit = topHabit;
    });
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

            if (mostConsistentHabit != null) ...[
              SizedBox(height: 12),
              Text("🏆 Most Consistent Habit:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${mostConsistentHabit!.name} (${mostConsistentHabit!.streak} days streak)"),
            ],
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