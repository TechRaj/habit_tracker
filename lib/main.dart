import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Main Dashboard with Stats
import 'screens/power_habits_screen.dart'; // 🚀 Power Habits
import 'screens/limit_habits_screen.dart'; // 🔒 Limit Habits

void main() {
  runApp(HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(), // 🌟 Main Navigation (Power & Limit Habits)
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // 🚀 New Pages: Main Dashboard, Power Habits, Limit Habits
  final List<Widget> _pages = [
    MainScreen(), // 📊 Main Insights & Streaks
    PowerHabitsScreen(), // 🚀 Build Good Habits
    LimitHabitsScreen(), // 🔒 Reduce Negative Habits
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: "Power Habits"), // 🚀
          BottomNavigationBarItem(icon: Icon(Icons.block), label: "Limit Habits"), // 🔒
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}