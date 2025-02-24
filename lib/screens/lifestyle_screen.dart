import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';

class LifestyleScreen extends StatefulWidget {
  @override
  _LifestyleScreenState createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('lifestyle_habits');
    if (savedData != null) {
      setState(() {
        habits = (json.decode(savedData) as List)
            .map((item) => Habit.fromJson(item))
            .toList();
      });
    } else {
      // Default Lifestyle Habits
      setState(() {
        habits = [
          Habit(name: "Screen Time < 2 Hours", progress: 0, goal: 2), // Limited habit
          Habit(name: "Limit Social Media Time", progress: 0, goal: 1), // Boolean habit
          Habit(name: "Stay Under Budget (\$50)", progress: 0, goal: 50), // Limited habit
        ];
      });
      _saveHabits();
    }
  }

  void _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lifestyle_habits', json.encode(habits.map((h) => h.toJson()).toList()));
  }

  void _updateHabitProgress(int index, int value) {
    setState(() {
      habits[index].progress = value;
      // If habit has a "limit", mark as failed if exceeded
      if (habits[index].progress > habits[index].goal) {
        habits[index].isCompleted = false; // Lost streak
      } else {
        habits[index].isCompleted = true; // Still within limit
      }
    });
    _saveHabits();
  }

  void _incrementBooleanHabit(int index, int change) {
    setState(() {
      habits[index].progress += change;
      if (habits[index].progress < 0) habits[index].progress = 0;
      habits[index].isCompleted = habits[index].progress > 0;
    });
    _saveHabits();
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
            title: Text("Add New Lifestyle Habit"),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("💰 Lifestyle Habits")),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          bool isBoolean = habits[index].goal == 1;
          bool isLimited = habits[index].name.contains("Screen Time") || habits[index].name.contains("Budget");

          return Dismissible(
            key: Key(habits[index].name),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await _showDeleteConfirmationDialog(index);
            },
            child: Card(
              child: ListTile(
                title: Text(habits[index].name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: habits[index].progress / habits[index].goal,
                      backgroundColor: Colors.grey[300],
                      color: habits[index].progress > habits[index].goal ? Colors.red : Colors.blue,
                      minHeight: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${habits[index].progress}/${habits[index].goal}"),
                        isBoolean
                            ? Row(
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        child: Icon(Icons.add),
        tooltip: "Add New Habit",
      ),
    );
  }
}