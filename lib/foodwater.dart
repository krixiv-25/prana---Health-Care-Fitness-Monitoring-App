import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kenko/logadd.dart';

class FoodWaterLog extends StatefulWidget {
  const FoodWaterLog({super.key});

  @override
  State<FoodWaterLog> createState() => _FoodWaterLogState();
}

class _FoodWaterLogState extends State<FoodWaterLog> {
  int _selectedIndex = 0;

  
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _glassesController = TextEditingController();

  Future<void> _addLog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final calories = double.tryParse(_caloriesController.text) ?? 0.0;
    final glasses = int.tryParse(_glassesController.text) ?? 0;

    if (_foodNameController.text.isNotEmpty && calories > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('food_logs')
          .add({
            'foodName': _foodNameController.text,
            'calories': calories,
            'timestamp': FieldValue.serverTimestamp(),
          });
    }

    if (glasses > 0) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('water_logs')
          .add({'glasses': glasses, 'timestamp': FieldValue.serverTimestamp()});
    }

    _foodNameController.clear();
    _caloriesController.clear();
    _glassesController.clear();
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
          "ADD TO FOOD AND WATER LOG",
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
                  controller: _foodNameController,
                  decoration: const InputDecoration(
                    hintText: "Food Name",
                    border: InputBorder.none,
                  ),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                TextField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    hintText: "Calories",
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                TextField(
                  controller: _glassesController,
                  decoration: const InputDecoration(
                    hintText: "Glasses of Water (Goal: 8)",
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
                    onPressed: _addLog,
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
              builder: (context) => LogAdd(),
              backgroundColor: Colors.white,
            );
          } else if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/map');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/mental');
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
