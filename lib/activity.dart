import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kenko/logadd.dart';

class ActivityLog extends StatefulWidget {
  const ActivityLog({super.key});

  @override
  State<ActivityLog> createState() => _ActivityLogState();
}

class _ActivityLogState extends State<ActivityLog> {
  int _selectedIndex = 0;

  
  final _activityNameController = TextEditingController();
  final _repsController = TextEditingController();
  final _minutesController = TextEditingController();
  final _caloriesController = TextEditingController();

  Future<void> _addActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final reps = int.tryParse(_repsController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final calories = double.tryParse(_caloriesController.text) ?? 0.0;

    if (_activityNameController.text.isNotEmpty && calories > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('activity_logs')
          .add({
            'activityName': _activityNameController.text,
            'reps': reps,
            'minutes': minutes,
            'calories': calories,
            'timestamp': FieldValue.serverTimestamp(),
          });
    }

    _activityNameController.clear();
    _repsController.clear();
    _minutesController.clear();
    _caloriesController.clear();
    Navigator.pushReplacementNamed(context, '/home'); 
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true,
        title: const Text(
          "ADD TO ACTIVITY LOG",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/profile',
              ); 
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 50),
                TextField(
                  controller: _activityNameController,
                  decoration: const InputDecoration(
                    hintText: "Activity Name",
                    border: InputBorder.none,
                  ),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                TextField(
                  controller: _repsController,
                  decoration: const InputDecoration(
                    hintText: "Reps",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                TextField(
                  controller: _minutesController,
                  decoration: const InputDecoration(
                    hintText: "Minutes",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                TextField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    hintText: "Calories Burned",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(70, 34, 85, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _addActivity,
                    child: const Text(
                      "ADD",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
              builder: (context) => LogAdd(),
            );
          } else if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
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
