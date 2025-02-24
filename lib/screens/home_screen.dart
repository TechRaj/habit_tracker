// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  _HabitHomePageState createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> {
  List<String> _habitLog = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _habitLog = (prefs.getStringList('habitLog') ?? []);
    });
  }

  void _logHabit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0];
    if (!_habitLog.contains(today)) {
      setState(() {
        _habitLog.add(today);
      });
      await prefs.setStringList('habitLog', _habitLog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Habit Tracker')),
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _logHabit,
            child: Text('Log Habit for Today'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _habitLog.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Habit logged on: ${_habitLog[index]}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}