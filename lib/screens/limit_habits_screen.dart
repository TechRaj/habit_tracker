import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';

class LimitHabitsScreen extends StatefulWidget {
  @override
  _LimitHabitsScreenState createState() => _LimitHabitsScreenState();
}

class _LimitHabitsScreenState extends State<LimitHabitsScreen> {
  List<Habit> habits = [];
  late ConfettiController _failConfettiController;

  @override
  void initState() {
    super.initState();
    checkAndResetHabits();
    _loadHabits();
    _failConfettiController = ConfettiController(duration: Duration(seconds: 1)); // 👎 Negative effect
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('limit_habits');
    if (savedData != null) {
      setState(() {
        habits = (json.decode(savedData) as List)
            .map((item) => Habit.fromJson(item))
            .toList();
      });
    } else {
      setState(() {
        habits = [
          Habit(name: "Screen Time < 2 Hours", progress: 0, goal: 2),
          Habit(name: "Social Media < 1 Hour", progress: 0, goal: 1),
          Habit(name: "Stay Under Budget (\$50)", progress: 0, goal: 50),
        ];
      });
      _saveHabits();
    }
  }

  void checkAndResetHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10);
    String? lastSavedDate = prefs.getString('last_saved_date');

    if (lastSavedDate == null || lastSavedDate != today) {
      setState(() {
        for (var habit in habits) {
          habit.progress = 0; // Reset progress for the new day
        }
      });
      prefs.setString('last_saved_date', today);
      _saveHabits();
    }
  }

  void _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('limit_habits', json.encode(habits.map((h) => h.toJson()).toList()));
  }

  void _updateHabitProgress(int index, int value) {
    setState(() {
      habits[index].progress = value;
      bool failed = habits[index].progress > habits[index].goal;

      if (failed) {
        habits[index].isCompleted = false;
        habits[index].streak = 0; // ❌ Streak is broken
        _triggerFailureEffects();
      } else {
        habits[index].isCompleted = true;
      }

      _saveHabits();
    });
  }

  void _triggerFailureEffects() {
    _failConfettiController.play(); // 👎 Thumbs Down Effect

    if (Vibration.hasVibrator() != null) {
      Vibration.vibrate(duration: 500); // 🚨 Short vibration feedback
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("👎 Oh no! You went over the limit!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _incrementBooleanHabit(int index, int change) {
    int newValue = (habits[index].progress + change).clamp(0, habits[index].goal);
    _updateHabitProgress(index, newValue);
  }

  void _showNumericInputDialog(int index) {
    TextEditingController controller = TextEditingController();
    controller.text = habits[index].progress.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Value for ${habits[index].name}"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Enter value"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                int newValue = int.tryParse(controller.text) ?? habits[index].progress;
                _updateHabitProgress(index, newValue);
                Navigator.of(context).pop();
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAddHabitDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController goalController = TextEditingController();
    bool isBooleanHabit = false;
    String? errorText;
    int goalThreshold = 10; // Define threshold for UI switching

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Allows live updates inside the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add New Health Habit"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Habit and Goal"),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isBooleanHabit,
                        onChanged: (value) {
                          setState(() {
                            isBooleanHabit = value!;
                          });
                        },
                      ),
                      Text("Track as Done/Not Done?"),
                    ],
                  ),
                  if (!isBooleanHabit)
                    TextField(
                      controller: goalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "How much?",
                        errorText: errorText, // Show error if needed
                      ),
                      onChanged: (value) {
                        setState(() {
                          int? parsedValue = int.tryParse(value);
                          errorText = (parsedValue == null || parsedValue <= 0) 
                              ? "Please enter a valid positive number" 
                              : null;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    String habitName = nameController.text.trim();
                    int? habitGoal = int.tryParse(goalController.text);

                    if (habitName.isEmpty) {
                      setState(() {
                        errorText = "Habit name cannot be empty";
                      });
                      return;
                    }

                    if (!isBooleanHabit && (habitGoal == null || habitGoal <= 0)) {
                      setState(() {
                        errorText = "Please enter a valid positive number";
                      });
                      return;
                    }

                    Navigator.of(context).pop(); // Close dialog before updating UI

                    setState(() {
                      int goal = isBooleanHabit ? 1 : habitGoal!;
                      habits.add(Habit(
                        name: habitName,
                        progress: 0,
                        goal: goal,
                      ));
                    });

                    _saveHabits();
                    _loadHabits(); // Refresh UI after adding
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
    _saveHabits();
  }

  Future<bool?> _showDeleteConfirmationDialog(int index) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Habit"),
          content: Text("Are you sure you want to delete this habit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _removeHabit(index);
                Navigator.of(context).pop(true);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🔒 Limit Habits")),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              bool isBoolean = habits[index].goal == 1;
              bool useButtons = habits[index].goal <= 10; // ✅ If goal is small, show `+` & `-` buttons

              return Card(
                child: ListTile(
                  title: Text(habits[index].name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Progress Bar
                      Row(
                        children: [
                          Expanded(
                            flex: 3, // 75% width for progress bar
                            child: LinearProgressIndicator(
                              value: habits[index].progress / habits[index].goal,
                              backgroundColor: Colors.grey[300],
                              color: habits[index].progress > habits[index].goal ? Colors.red : Colors.blue,
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(width: 12),

                          // ✅ Streak Counter (🔥 or ❄️)
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              habits[index].streak > 0 ? "🔥 ${habits[index].streak}" : "❄️ 0",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: habits[index].streak > 0 ? Colors.orange : Colors.blue,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),

                      // ✅ Row: Progress Count & Right-Aligned Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ✅ Progress Text
                          Text("${habits[index].progress}/${habits[index].goal}"),

                          // ✅ Right-Aligned Buttons
                          Align(
                            alignment: Alignment.centerRight,
                            child: isBoolean || useButtons
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove, color: Colors.red),
                                        onPressed: () => _incrementBooleanHabit(index, -1),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add, color: Colors.green),
                                        onPressed: () => _incrementBooleanHabit(index, 1),
                                      ),
                                    ],
                                  )
                                : ElevatedButton(
                                    onPressed: () => _showNumericInputDialog(index),
                                    child: Text("Enter Value"),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 👎 Thumbs Down Rain Effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _failConfettiController,
              blastDirection: 3.14 / 2, // Falls downward
              blastDirectionality: BlastDirectionality.explosive,
              colors: [Colors.red, Colors.black], // Failure colors
              numberOfParticles: 40,
              gravity: 1,
              minBlastForce: 5,
              maxBlastForce: 10,
              shouldLoop: false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: Icon(Icons.add),
        tooltip: "Add New Habit",
      ),
    );
  }
}