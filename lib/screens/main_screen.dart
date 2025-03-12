import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Habit> habits = [];
  int completedToday = 0;
  int totalStreaks = 0;
  List<Habit> topThreeHabits = [];
  Map<int, Map<String, int>> weeklyProgress = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = ['power_habits', 'limit_habits'];
    List<Habit> powerHabits = [];
    List<Habit> limitHabits = [];

    for (String key in keys) {
      String? savedData = prefs.getString(key);
      if (savedData != null) {
        List<Habit> habitsList = (json.decode(savedData) as List)
            .map((item) => Habit.fromJson(item))
            .toList();

        for (var habit in habitsList) {
          if (key == 'power_habits') {
            powerHabits.add(habit);
          } else {
            limitHabits.add(habit);
          }
        }
      }
    }

    List<Habit> allHabits = [...powerHabits, ...limitHabits];
    int completed = allHabits.where((h) => h.isCompleted).length;
    int streaks = allHabits.fold(0, (sum, h) => sum + h.streak);
    List<Habit> sortedHabits = List.from(allHabits)
      ..sort((a, b) => b.streak.compareTo(a.streak));
    List<Habit> topThree = sortedHabits.take(3).toList();

    Map<int, Map<String, int>> progressData = {};
    for (var habit in allHabits) {
      int weekday = DateTime.now().weekday;
      if (!progressData.containsKey(weekday)) {
        progressData[weekday] = {'power': 0, 'limit': 0};
      }
      if (habit.isCompleted) {
        if (powerHabits.contains(habit)) {
          progressData[weekday]!['power'] =
              (progressData[weekday]!['power'] ?? 0) + 1;
        } else {
          progressData[weekday]!['limit'] =
              (progressData[weekday]!['limit'] ?? 0) + 1;
        }
      }
    }

    setState(() {
      habits = allHabits;
      completedToday = completed;
      totalStreaks = streaks;
      topThreeHabits = topThree;
      weeklyProgress = progressData;
    });
  }

  Widget _buildDailyProgress() {
    return Card(
    //color: Color.fromRGBO(255, 255, 255, 0.8), // Makes the widget slightly transparent using RGBO
      margin: EdgeInsets.all(12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📊 Daily Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: habits.isNotEmpty ? completedToday / habits.length : 0,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
                minHeight: 10,
              ),
            ),
            SizedBox(height: 8),
            Text("Completed: $completedToday / ${habits.length} habits"),
          ],
        ),
      ),
    );
  }

  Widget _buildBestHabits() {
    return Card(
    //color: Color.fromRGBO(255, 255, 255, 0.8), // Makes the widget slightly transparent using RGBO
      margin: EdgeInsets.all(12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🏆 Top 3 Best Habits",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...topThreeHabits.asMap().entries.map((entry) {
              int rank = entry.key + 1;
              Habit habit = entry.value;
              return Text("$rank. ${habit.name} - ${habit.streak} days 🔥",
                  style: TextStyle(fontSize: 16));
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart() {
    return Card(
    //color: Color.fromRGBO(255, 255, 255, 0.8), // Makes the widget slightly transparent using RGBO
      margin: EdgeInsets.all(12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📅 Weekly Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                          return Text(weekDays[value.toInt() % 7], style: TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(7, (index) {
                    int day = index + 1;
                    int powerCount = weeklyProgress[day]?['power'] ?? 0;
                    int limitCount = weeklyProgress[day]?['limit'] ?? 0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(toY: powerCount.toDouble(), color: Colors.green, width: 8, borderRadius: BorderRadius.zero),
                        BarChartRodData(toY: limitCount.toDouble(), color: Colors.red, width: 8, borderRadius: BorderRadius.zero),
                      ],
                      barsSpace: 0,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, 
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "🎯 Dashboard",
          style: GoogleFonts.roboto(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black, 
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildDailyProgress(),
          _buildBestHabits(),
          _buildWeeklyProgressChart(),
        ],
      ),
    );
  }
}