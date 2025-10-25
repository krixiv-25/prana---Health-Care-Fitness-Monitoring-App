import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;


  Future<void> _login() async {
    final email =
        _usernameController.text.trim(); 
    final password =
        _passwordController.text.trim(); 

  
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(99, 75, 102, 1),
      
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 50, 10, 50),
              child: Text(
                "Prānā",
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
                        "Welcome!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const Text("Log in to continue"),
                      const SizedBox(height: 20),
                      
                      TextField(
                        controller:
                            _usernameController, 
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          labelText: "Enter Email", 
                          hintStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ), 
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      TextField(
                        controller: _passwordController,

                        textAlign: TextAlign.left,
                        obscureText:
                            _obscurePassword, 
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

                      const SizedBox(height: 40),

                     
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
                                borderRadius: BorderRadius.circular(
                                  50.0,
                                ), 
                              ),
                            ),
                            onPressed: _login, 
                            child: const Text(
                              "LOG IN",
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
                          onTap: () {
                           
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: const Text(
                            "Not registered yet? Register", 
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
