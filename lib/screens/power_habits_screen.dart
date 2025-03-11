import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

class PowerHabitsScreen extends StatefulWidget {
  const PowerHabitsScreen({super.key});

  @override
  _PowerHabitsScreenState createState() => _PowerHabitsScreenState();
}

class _PowerHabitsScreenState extends State<PowerHabitsScreen> {
  List<Habit> habits = [];
  Map<String, bool> expandedState = {}; // Track which habits are expanded
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    checkAndResetHabits();
    _loadHabits();
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('power_habits');
    for (var habit in habits) {
      expandedState.putIfAbsent(habit.name, () => false);
    }
    if (savedData != null) {
      setState(() {
        habits = (json.decode(savedData) as List)
            .map((item) => Habit.fromJson(item))
            .toList();
      });
    } else {
      setState(() {
        habits = [
          Habit(name: "Exercise (30 min)", progress: 0, goal: 30),
          Habit(name: "Read 30 minutes", progress: 0, goal: 30),
          Habit(name: "Meditate 10 minutes", progress: 0, goal: 10),
          Habit(name: "Code for 1 hour", progress: 0, goal: 60),
        ];
      });
      _saveHabits();
    }
    _loadHabitHistory();
  }

  void _loadHabitHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var habit in habits) {
      List<String> history = prefs.getStringList('history_${habit.name}') ?? List.filled(7, '⚪');
      habit.history = history;
    }
  }

  void _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('power_habits', json.encode(habits.map((h) => h.toJson()).toList()));
  }

  void _showConfetti() {
    _confettiController.play();
  }

  void checkAndResetHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10); // YYYY-MM-DD
    String? lastSavedDate = prefs.getString('last_saved_date');

    if (lastSavedDate == null || lastSavedDate != today) {
      setState(() {
        for (var habit in habits) {
          habit.progress = 0; // ✅ Reset progress
          habit.isCompleted = false; // ✅ Reset completion flag
        }
      });
      prefs.setString('last_saved_date', today);
      _saveHabits();
    }
  }

  void _updateHabitProgress(int index, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10); // YYYY-MM-DD
    String? lastCompletedDate = prefs.getString('last_completed_date_${habits[index].name}');

    setState(() {
      habits[index].progress = value;
      bool completed = habits[index].progress >= habits[index].goal;

      if (completed && !habits[index].isCompleted) {
        habits[index].isCompleted = true;
        prefs.setString('last_completed_date_${habits[index].name}', today); // ✅ Save completion date
      } 

      // ❌ If user missed a day, streak resets
      if (lastCompletedDate != null && lastCompletedDate != today) {
        habits[index].streak = 0;
      }

      // ✅ If completed on a new day, increase streak
      if (completed && lastCompletedDate != today) {
        habits[index].streak += 1;
        _showConfetti(); // 🎉 Show confetti
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 Congratulations! You've hit your goal!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      _updateHabitHistory(index, completed);
    });

    _saveHabits();
  }

  void _updateHabitHistory(int index, bool completed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history_${habits[index].name}') ?? List.filled(7, '⚪');

    history.add(completed ? '🟢' : '🔴');
    if (history.length > 7) history.removeAt(0);

    prefs.setStringList('history_${habits[index].name}', history);
    setState(() {
      habits[index].history = history;
    });
  }

  double _calculateConsistency(Habit habit) {
    int completedDays = habit.history.where((day) => day == '🟢').length;
    int totalTrackedDays = habit.history.where((day) => day != '⚪').length;
  
    if (totalTrackedDays == 0) return 0; // ✅ Prevent division by zero

    return (completedDays / totalTrackedDays) * 100;
  }

  void _incrementBooleanHabit(int index, int change) {
    int newValue = habits[index].progress + change;
    if (newValue < 0) newValue = 0;

    if (change < 0 && habits[index].streak > 0 && habits[index].progress >= habits[index].goal) {
      habits[index].streak -= 1; // ✅ Reduce streak if user decrements after completion
    }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "🚀 Power Habits",
          style: GoogleFonts.roboto(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              bool isBoolean = habits[index].goal == 1;
              bool useButtons = habits[index].goal <= 10;

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
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(habits[index].name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ First Row: Progress Bar & Streak Display
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: LinearProgressIndicator(
                                    value: habits[index].progress / habits[index].goal,
                                    backgroundColor: Colors.grey[300],
                                    color: habits[index].progress >= habits[index].goal ? Colors.green : Colors.blue,
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                SizedBox(width: 12),
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

                            // ✅ Second Row: Buttons & Expansion Arrow
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ✅ Progress Count
                                Text("${habits[index].progress}/${habits[index].goal}"),

                                // ✅ Right-Aligned Buttons & Expansion Arrow
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isBoolean || useButtons) ...[
                                      IconButton(
                                        icon: Icon(Icons.remove, color: Colors.red),
                                        onPressed: () => _incrementBooleanHabit(index, -1),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add, color: Colors.green),
                                        onPressed: () => _incrementBooleanHabit(index, 1),
                                      ),
                                    ] else ...[
                                      ElevatedButton(
                                        onPressed: () => _showNumericInputDialog(index),
                                        child: Text("Enter Value"),
                                      ),
                                    ],

                                    // ✅ Expansion Arrow
                                    IconButton(
                                      icon: Icon(expandedState[habits[index].name] ?? false
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down),
                                      onPressed: () {
                                        setState(() {
                                          expandedState[habits[index].name] = !(expandedState[habits[index].name] ?? false);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                        // ✅ Expanded Habit History & Consistency
                        if (expandedState[habits[index].name] ?? false) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                            alignment: Alignment.centerLeft, // Ensures alignment to the left
                            child: Text(
                              "📅 Past 7 Days: ${habits[index].history?.join(' ') ?? '⚪⚪⚪⚪⚪⚪⚪'}",
                              style: TextStyle(fontSize: 16),
                            ),
                            ),
                            Align(
                            alignment: Alignment.centerLeft, // Ensures alignment to the left
                            child: Text(
                              "📊 Consistency: ${_calculateConsistency(habits[index]).toStringAsFixed(1)}%",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            ),
                          ],
                          ),
                        ),
                        ],
                      ],
                      ),
                    ),
                    );
                  },
                  ),

          // 🔥 Confetti Effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3.14 / 2,
              blastDirectionality: BlastDirectionality.explosive,
              colors: [Colors.blue, Colors.green, Colors.purple, Colors.orange],
              numberOfParticles: 50,
              gravity: 1,
              maxBlastForce: 15,
              minBlastForce: 8,
              shouldLoop: false,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showAddHabitDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              "Add New Habit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
