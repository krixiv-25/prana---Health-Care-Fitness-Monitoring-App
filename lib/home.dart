import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kenko/logadd.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; 
  String _username = "User"; 

  
  final Health _health = Health();
  int _totalSteps = 0;
  double _totalDistance = 0.0; 
  Timer? _timer;

  
  double? dailyCalorieGoal;
  double consumedCalories = 0; 
  double activityCalories = 0; 
  List<Map<String, dynamic>> foodLogs = [];
  List<Map<String, dynamic>> activityLogs = [];

  
  final int waterGoal = 8; 
  int totalGlasses = 0;
  List<Map<String, dynamic>> waterLogs = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _fetchUsername();
    _fetchUserData();
    _fetchFoodLogs();
    _fetchWaterLogs();
    _fetchActivityLogs();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchStepData(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();
    if (Platform.isAndroid) {
      if (!await Permission.activityRecognition.isGranted) {
        await Permission.activityRecognition.request();
      }
    }
    await _fetchStepData();
  }

  Future<void> _fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _username = doc.get('username') ?? "User";
        });
      }
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      final weight = data['weight'] as double;
      final height = data['height'] as double;
      final age = data['age'] as int;
      final gender = data['gender'] as String;

      
      double bmr =
          (gender == 'Male')
              ? (10 * weight) + (6.25 * height) - (5 * age) + 5
              : (10 * weight) + (6.25 * height) - (5 * age) - 161;
      
      dailyCalorieGoal = bmr * 0.8;
      setState(() {});
    }
  }

  Future<void> _fetchFoodLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('food_logs')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      consumedCalories = 0; 
      foodLogs =
          snapshot.docs.map((doc) {
            final data = doc.data();
            consumedCalories += (data['calories'] as num).toDouble();
            return {
              'id': doc.id,
              'foodName': data['foodName'],
              'calories': (data['calories'] as num).toDouble(),
              'timestamp': (data['timestamp'] as Timestamp).toDate(),
            };
          }).toList();
    });
  }

  Future<void> _fetchWaterLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('water_logs')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      totalGlasses = 0; 
      waterLogs =
          snapshot.docs.map((doc) {
            final data = doc.data();
            final glasses = (data['glasses'] as num).toInt(); 
            totalGlasses += glasses;
            return {
              'id': doc.id,
              'glasses': glasses,
              'timestamp': (data['timestamp'] as Timestamp).toDate(),
            };
          }).toList();
    });
  }

  Future<void> _fetchActivityLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('activity_logs')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      activityCalories = 0; 
      activityLogs =
          snapshot.docs.map((doc) {
            final data = doc.data();
            activityCalories += (data['calories'] as num).toDouble();
            return {
              'id': doc.id,
              'activityName': data['activityName'],
              'reps': (data['reps'] as num).toInt(),
              'minutes': (data['minutes'] as num).toInt(),
              'calories': (data['calories'] as num).toDouble(),
              'timestamp': (data['timestamp'] as Timestamp).toDate(),
            };
          }).toList();
    });
  }

  Future<void> _deleteFoodLog(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('food_logs')
        .doc(id)
        .delete();
    _fetchFoodLogs(); 
  }

  Future<void> _deleteWaterLog(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = waterLogs.firstWhere((log) => log['id'] == id);
    totalGlasses -= log['glasses'] as int;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('water_logs')
        .doc(id)
        .delete();
    _fetchWaterLogs(); 
  }

  Future<void> _deleteActivityLog(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = activityLogs.firstWhere((log) => log['id'] == id);
    activityCalories -= log['calories'];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activity_logs')
        .doc(id)
        .delete();
    _fetchActivityLogs(); 
  }

  Future<void> _editFoodLog(
    String id,
    String newFoodName,
    double newCalories,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = foodLogs.firstWhere((log) => log['id'] == id);
    consumedCalories += newCalories - log['calories'];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('food_logs')
        .doc(id)
        .update({
          'foodName': newFoodName,
          'calories': newCalories,
          'timestamp': FieldValue.serverTimestamp(),
        });
    _fetchFoodLogs();
  }

  Future<void> _editWaterLog(String id, int newGlasses) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = waterLogs.firstWhere((log) => log['id'] == id);
    totalGlasses += newGlasses - (log['glasses'] as int);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('water_logs')
        .doc(id)
        .update({
          'glasses': newGlasses,
          'timestamp': FieldValue.serverTimestamp(),
        });
    _fetchWaterLogs(); 
  }

  Future<void> _editActivityLog(
    String id,
    String newActivityName,
    int newReps,
    int newMinutes,
    double newCalories,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = activityLogs.firstWhere((log) => log['id'] == id);
    activityCalories += newCalories - log['calories'];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activity_logs')
        .doc(id)
        .update({
          'activityName': newActivityName,
          'reps': newReps,
          'minutes': newMinutes,
          'calories': newCalories,
          'timestamp': FieldValue.serverTimestamp(),
        });
    _fetchActivityLogs(); 
  }

  void _showEditFoodDialog(
    BuildContext context,
    String id,
    String foodName,
    double calories,
  ) {
    final foodController = TextEditingController(text: foodName);
    final calorieController = TextEditingController(text: calories.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Food Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: foodController,
                  decoration: InputDecoration(labelText: 'Food Name'),
                ),
                TextField(
                  controller: calorieController,
                  decoration: InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newCalories =
                      double.tryParse(calorieController.text) ?? 0.0;
                  _editFoodLog(id, foodController.text, newCalories);
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showEditWaterDialog(BuildContext context, String id, int glasses) {
    final glassesController = TextEditingController(text: glasses.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Water Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: glassesController,
                  decoration: InputDecoration(labelText: 'Glasses'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newGlasses = int.tryParse(glassesController.text) ?? 0;
                  _editWaterLog(id, newGlasses);
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showEditActivityDialog(
    BuildContext context,
    String id,
    String activityName,
    int reps,
    int minutes,
    double calories,
  ) {
    final activityController = TextEditingController(text: activityName);
    final repsController = TextEditingController(text: reps.toString());
    final minutesController = TextEditingController(text: minutes.toString());
    final calorieController = TextEditingController(text: calories.toString());

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Activity Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: activityController,
                  decoration: InputDecoration(labelText: 'Activity Name'),
                ),
                TextField(
                  controller: repsController,
                  decoration: InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: minutesController,
                  decoration: InputDecoration(labelText: 'Minutes'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: calorieController,
                  decoration: InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newReps = int.tryParse(repsController.text) ?? 0;
                  final newMinutes = int.tryParse(minutesController.text) ?? 0;
                  final newCalories =
                      double.tryParse(calorieController.text) ?? 0.0;
                  _editActivityLog(
                    id,
                    activityController.text,
                    newReps,
                    newMinutes,
                    newCalories,
                  );
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _fetchStepData() async {
    await _health.configure();

    final types = [HealthDataType.STEPS, HealthDataType.DISTANCE_DELTA];

    bool granted = await _health.requestAuthorization(types);
    if (!granted) {
      debugPrint("Permission not granted to read steps and distance.");
      return;
    }

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    int? steps = await _health.getTotalStepsInInterval(midnight, now);

    double totalDistance = 0.0;

    try {
      List<HealthDataPoint> distanceData = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: [HealthDataType.DISTANCE_DELTA],
      );

      debugPrint("Found ${distanceData.length} distance data points");

      for (var point in distanceData) {
        var value = point.value;
        if (value is NumericHealthValue) {
          totalDistance += value.numericValue.toDouble();
          debugPrint("Added distance: ${value.numericValue}");
        }
      }
    } catch (e) {
      debugPrint("Error fetching distance data: $e");
    }

    if (totalDistance == 0.0 && steps != null && steps > 0) {
      totalDistance = steps * 0.8; 
      debugPrint("Estimated distance from steps: $totalDistance meters");
    }

    debugPrint("Final total distance: $totalDistance meters");

    setState(() {
      _totalSteps = steps ?? 0;
      _totalDistance = totalDistance;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _startNewDay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    
    bool confirm =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text('Start New Day'),
                content: Text(
                  'Are you sure you want to reset today\'s data? This will clear all food, water, and step records for the current day.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Confirm'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      
      final foodSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('food_logs')
              .get();
      for (var doc in foodSnapshot.docs) {
        await doc.reference.delete();
      }

      
      final waterSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('water_logs')
              .get();
      for (var doc in waterSnapshot.docs) {
        await doc.reference.delete();
      }

      
      final activitySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('activity_logs')
              .get();
      for (var doc in activitySnapshot.docs) {
        await doc.reference.delete();
      }

      
      setState(() {
        consumedCalories = 0;
        activityCalories = 0;
        foodLogs.clear();
        activityLogs.clear();
        totalGlasses = 0;
        waterLogs.clear();
        _totalSteps = 0;
        _totalDistance = 0.0;
      });

      
      await _fetchStepData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true,
        title: Text(
          "HOME",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Welcome, $_username!",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 8, 5, 5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                height: 50,
                width: double.infinity,
                color: const Color.fromRGBO(229, 255, 222, 170),
                child: Center(
                  child: Text(
                    "Steps: $_totalSteps",
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey[800]),
                  ),
                ),
              ),
              Container(
                height: 50,
                width: double.infinity,
                color: const Color.fromRGBO(187, 203, 203, 170),
                child: Center(
                  child: Text(
                    "Distance: ${(_totalDistance / 1000).toStringAsFixed(2)} km",
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey[800]),
                  ),
                ),
              ),
              TextButton(
                onPressed: _fetchStepData,
                child: Center(child: Text("Refresh Step Data")),
              ),
              const SizedBox(height: 20),
             
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (dailyCalorieGoal != null)
                    Column(
                      children: [
                        Text(
                          "Calories: $consumedCalories kcal",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: DoughnutChart(
                            title: "Calories",
                            goal: dailyCalorieGoal! + activityCalories,
                            consumed: consumedCalories,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        "Water: $totalGlasses glasses",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: DoughnutChart(
                          title: "Water",
                          goal: waterGoal.toDouble(),
                          consumed: totalGlasses.toDouble(),
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Food Log",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: foodLogs.length,
                itemBuilder: (context, index) {
                  final log = foodLogs[index];
                  return ListTile(
                    title: Text(log['foodName']),
                    subtitle: Text(
                      '${log['calories']} kcal - ${DateFormat('MM/dd HH:mm').format(log['timestamp'])}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed:
                              () => _showEditFoodDialog(
                                context,
                                log['id'],
                                log['foodName'],
                                log['calories'],
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteFoodLog(log['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Water Log",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: waterLogs.length,
                itemBuilder: (context, index) {
                  final log = waterLogs[index];
                  return ListTile(
                    title: Text('${log['glasses']} glass(es)'),
                    subtitle: Text(
                      DateFormat('MM/dd HH:mm').format(log['timestamp']),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed:
                              () => _showEditWaterDialog(
                                context,
                                log['id'],
                                log['glasses'],
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteWaterLog(log['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Activity Log",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: activityLogs.length,
                itemBuilder: (context, index) {
                  final log = activityLogs[index];
                  return ListTile(
                    title: Text(log['activityName']),
                    subtitle: Text(
                      '${log['reps']} reps, ${log['minutes']} min - ${log['calories']} kcal - ${DateFormat('MM/dd HH:mm').format(log['timestamp'])}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed:
                              () => _showEditActivityDialog(
                                context,
                                log['id'],
                                log['activityName'],
                                log['reps'],
                                log['minutes'],
                                log['calories'],
                              ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteActivityLog(log['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              Center(
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(70, 34, 85, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          50.0,
                        ), // Rounded edges
                      ),
                    ),
                    onPressed: _startNewDay,
                    child: const Text(
                      'NEW DAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(24, 2, 12, 1),
        unselectedItemColor: const Color.fromRGBO(149, 144, 168, 1),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 2) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              builder: (context) => const LogAdd(),
            );
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/map');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/mental');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            _onItemTapped(index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Mental',
          ),
        ],
      ),
    );
  }
}

class DoughnutChart extends StatelessWidget {
  final String title;
  final double goal;
  final double consumed;
  final Color color;

  const DoughnutChart({
    super.key,
    required this.title,
    required this.goal,
    required this.consumed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: color,
                  value: consumed,
                  title: '$consumed',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                PieChartSectionData(
                  color: color.withOpacity(0.3),
                  value: remaining > 0 ? remaining : 0,
                  title: remaining > 0 ? remaining.toStringAsFixed(0) : '0',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
