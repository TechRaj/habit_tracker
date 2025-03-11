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
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: HomePage(), // 🌟 Main Navigation (Swipe between Pages)
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  // 🚀 Pages: Main Dashboard, Power Habits, Limit Habits
  final List<Widget> _pages = [
    MainScreen(), // 📊 Main Insights & Streaks
    PowerHabitsScreen(), // 🚀 Build Good Habits
    LimitHabitsScreen(), // 🔒 Reduce Negative Habits
  ];

  // 🎨 Background Colors for Each Page
  final List<Color> _backgroundColors = [
    Colors.lightBlueAccent,  // Main Screen
    Colors.greenAccent, // Power Habits
    Colors.redAccent,   // Limit Habits
  ];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _backgroundColors[_selectedIndex].withAlpha(200),
            _backgroundColors[_selectedIndex],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: BouncingScrollPhysics(), // ✅ Enables swipe gestures in Chrome & mobile
        children: _pages,
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      selectedItemColor: _backgroundColors[_selectedIndex], // Match selected color with page color
      unselectedItemColor: Colors.grey, // Keep unselected items neutral
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: "Power Habits"),
        BottomNavigationBarItem(icon: Icon(Icons.block), label: "Limit Habits"),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    ),
  );
}
}