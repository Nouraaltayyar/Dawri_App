import 'package:flutter/material.dart';
import 'package:dawri_app/services/auth_services.dart';
import 'package:dawri_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscurePassword = true;
  int selectedRole = 0;

  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  Future<void> _login() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential userCredential =
          await _authService.signInWithEmail(email: email, password: password);
      await _navigateBasedOnRole(userCredential.user!);
    } catch (e) {
      _showError("Login failed: $e");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        await _navigateBasedOnRole(userCredential.user!);
      }
    } catch (e) {
      _showError("Google login error: $e");
    }
  }

  Future<void> _navigateBasedOnRole(User user) async {
    final userData = await _dbService.getUserData(user.uid);
    if (userData == null) {
      _showError("User data not found.");
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user.email ?? '');
    final role = userData['role'];

    if (role == 'admin') {
      Navigator.pushNamed(context, "/adminHP");
    } else if (role == 'owner') {
      Navigator.pushNamed(context, "/ownerHP");
    } else {
      Navigator.pushNamed(context, "/home");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 100, bottom: 95),
            decoration: BoxDecoration(
              color: Color(0xFF53336F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Good to see you again!",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Let's get you logged in",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Center(
                  child: Container(
                    //width: 370,
                    height: 53,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(9),
                      selectedColor: Colors.white,
                      color: Colors.black,
                      fillColor: Color(0xFFc19dda),
                      constraints: BoxConstraints(
                        minWidth: 150,
                        minHeight: 53,
                      ),
                      isSelected: [selectedRole == 0, selectedRole == 1],
                      onPressed: (index) {
                        setState(() {
                          selectedRole = index;
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60),
                          child: Text("User"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60),
                          child: Text("Owner"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF664187)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: _isObscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF664187)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscurePassword = !_isObscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/forgot");
                      },
                      child: Text(
                        "I forgot my password!",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF53336F),
                      padding:
                          EdgeInsets.symmetric(horizontal: 150, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontFamily: 'Telex',
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      if (selectedRole == 1) {
                        Navigator.pushNamed(context, "/ownerSignup");
                      } else {
                        Navigator.pushNamed(context, "/signup");
                      }
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "Don’t have an account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "or continue with",
                          style: TextStyle(
                              color: Colors.grey, fontFamily: 'Poppins'),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.white),
                    label: Text("Continue with Google"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF664187),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
