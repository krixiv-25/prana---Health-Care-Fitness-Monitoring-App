import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final _usernameController =
      TextEditingController(); 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  
  String password = '';

 
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  
  bool get isLengthValid => password.length >= 8; 
  bool get hasUpperAndLower => RegExp(
    r'(?=.*[a-z])(?=.*[A-Z])',
  ).hasMatch(password); 
  bool get hasSpecialChar => RegExp(
    r'[!@#\$%\^&\*]',
  ).hasMatch(password); 


  Widget _buildRule(String text, bool passed) {
    return Row(
      children: [
        Icon(
          passed
              ? Icons.check_circle
              : Icons.cancel, 
          color: passed ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: passed ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

 
  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final passwordText = _passwordController.text.trim();
    final confirmPasswordText = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim(); 

   
    if (email.isEmpty ||
        passwordText.isEmpty ||
        confirmPasswordText.isEmpty ||
        username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required.")));
      return;
    }

    if (passwordText != confirmPasswordText) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    
    if (!isLengthValid || !hasUpperAndLower || !hasSpecialChar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fix the password requirements.")),
      );
      return;
    }

    try {
      
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: passwordText);
      User? user = userCredential.user;

      if (user != null) {
        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        Navigator.pushReplacementNamed(context, '/heightweight');
      }
    } on FirebaseAuthException catch (e) {
   
      String errorMessage = "Signup failed.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Email already in use.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password too weak.";
      }

      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
      // --- Body ---
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
              child: Text(
                "KENKO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create your account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const Text("Sign up to continue"),
                      const SizedBox(height: 20),
                      
                      TextField(
                        controller: _usernameController,
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                     
                      TextField(
                        controller: _emailController,
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      TextField(
                        controller: _passwordController,
                        textAlign: TextAlign.left,
                        obscureText: _obscurePassword,
                        onChanged: (val) {
                          setState(() {
                            password =
                                val; 
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons
                                      .visibility_off 
                                  : Icons.visibility, 
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                 
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Password must contain:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildRule("8 or more characters", isLengthValid),
                      _buildRule(
                        "At least 1 uppercase & 1 lowercase",
                        hasUpperAndLower,
                      ),
                      _buildRule(
                        "1 special character (!@#\$%^&*)",
                        hasSpecialChar,
                      ),
                      const SizedBox(height: 30),
                     
                      Center(
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                70,
                                34,
                                85,
                                1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                            onPressed: _signup, 
                            child: const Text(
                              "SIGN UP",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      
                      Center(
                        child: GestureDetector(
                          onTap:
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Login(),
                                ),
                              ),
                          child: const Text(
                            "Already have an account? Log in",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
