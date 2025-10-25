import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 

class UpdateDetails extends StatefulWidget {
  const UpdateDetails({super.key});

  @override
  State<UpdateDetails> createState() => _UpdateDetailsState();
}

class _UpdateDetailsState extends State<UpdateDetails> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _gender;
  DateTime? _dob;
  int? _age;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); 
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _heightController.text = (doc.get('height')?.toString() ?? '');
          _weightController.text = (doc.get('weight')?.toString() ?? '');
          _gender = doc.get('gender') as String?;
          _dob =
              doc.get('dob') != null
                  ? DateTime.parse(doc.get('dob') as String)
                  : null;
        });
      }
    }
  }

  Future<void> _saveAndContinue() async {
    final height = double.tryParse(_heightController.text.trim()) ?? 0.0;
    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;

    if (height <= 0 || weight <= 0 || _gender == null || _dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields with valid numbers."),
        ),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        
        final now =
            DateTime.now(); 
        _age = now.year - _dob!.year;
        if (_dob!.month > now.month ||
            (_dob!.month == now.month && _dob!.day > now.day)) {
          _age = _age! - 1; 
        }

        
        final heightInMeters = height / 100;
        final bmi = weight / (heightInMeters * heightInMeters);

      
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              'height': height,
              'weight': weight,
              'gender': _gender,
              'dob': _dob!.toIso8601String(), 
              'age': _age, 
              'bmi': bmi, 
            });

 
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('weight_logs')
            .add({'weight': weight, 'timestamp': FieldValue.serverTimestamp()});

        Navigator.pop(context); 
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true,
        title: Text(
          "UPDATE YOUR DETAILS",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Height (cm)",
                    border: InputBorder.none,
                  ),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Weight (kg)",
                    border: InputBorder.none,
                  ),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 20),
                const Text(
                  "Gender",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: "Male",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    const Text("Male"),
                    Radio<String>(
                      value: "Female",
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                    const Text("Female"),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Date of Birth",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: TextEditingController(
                        text:
                            _dob != null
                                ? DateFormat('yyyy-MM-dd').format(_dob!)
                                : '',
                      ),
                      decoration: const InputDecoration(
                        hintText: "Select Date",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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
                    onPressed: _saveAndContinue,
                    child: const Text(
                      "SAVE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
