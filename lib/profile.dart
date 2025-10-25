import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Updemail.dart';
import 'upddetails.dart'; 

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _username = "User"; 

  @override
  void initState() {
    super.initState();
    _fetchUsername(); 
  }

  Future<void> _fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
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


  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 

      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
        centerTitle: true, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home'); 
          },
        ),
        title: Text(
          "PROFILE", 
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 30), 
       
          const CircleAvatar(
            radius: 45, 
            backgroundColor: Color.fromRGBO(24, 2, 12, 1), 
            child: Icon(
              Icons.account_circle,
              size: 50,
              color: Colors.white, 
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Hello, $_username!",
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          const SizedBox(height: 40),

         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0), 
            child: Column(
              children: [
                
                ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: const Color.fromRGBO(70, 34, 85, 1),
                  ), 
                  title: const Text(
                    "Update Email",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpdateEmail()),
                    );
                  },
                ),
                const Divider(thickness: 1), 
                
                ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: const Color.fromRGBO(70, 34, 85, 1)
                  ), 
                  title: const Text(
                    "Update Personal Details",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UpdateDetails()),
                    );
                  },
                ),
                const Divider(thickness: 1), 
                
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: const Color.fromRGBO(70, 34, 85, 1),
                  ), 
                  title: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () => _logout(context), 
                ),
                const Divider(thickness: 1), 
              ],
            ),
          ),
        ],
      ),
    );
  }
}