import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/auth_services.dart';

class OwnerSignupPage extends StatefulWidget {
  @override
  _OwnerSignupPageState createState() => _OwnerSignupPageState();
}

class _OwnerSignupPageState extends State<OwnerSignupPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? selectedActivity;
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;

  Future<void> _registerOwner() async {
    try {
      UserCredential userCredential = await AuthService().signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await DatabaseService().createOwner(
        uid: userCredential.user!.uid,
        name: nameController.text.trim(),
        city: cityController.text.trim(),
        email: emailController.text.trim(),
        activity: selectedActivity ?? '',
      );

      Navigator.pushNamed(context, "/welcome");
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  final List<String> activityOptions = [
    'Event',
    'Restaurant',
    'Cafe',
    'Health care',
    'Bank'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Welcome onboard as an owner",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color(0xFF53336f),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                _buildTextField(
                  controller: nameController,
                  hint: "Name",
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? "Name cannot be empty" : null,
                ),
                SizedBox(height: 15),
                _buildTextField(
                  controller: cityController,
                  hint: "City",
                  icon: Icons.location_city,
                  validator: (value) =>
                      value!.isEmpty ? "City cannot be empty" : null,
                ),
                SizedBox(height: 15),
                _buildDropdownField(),
                SizedBox(height: 15),
                _buildTextField(
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      !value!.contains('@') ? "Enter a valid email" : null,
                ),
                SizedBox(height: 15),
                _buildPasswordField(passwordController, "Password"),
                SizedBox(height: 15),
                _buildPasswordField(
                    confirmPasswordController, "Confirm Password"),
                SizedBox(height: 30),
                _buildSignupButton(),
                SizedBox(height: 20),
                _buildLoginLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon, color: Color(0xFF664187)),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    bool isConfirm = hint == "Confirm Password";
    return TextFormField(
      controller: controller,
      obscureText: isConfirm ? _isObscureConfirmPassword : _isObscurePassword,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.lock, color: Color(0xFF664187)),
        suffixIcon: IconButton(
          icon: Icon(
            (isConfirm ? _isObscureConfirmPassword : _isObscurePassword)
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _isObscureConfirmPassword = !_isObscureConfirmPassword;
              } else {
                _isObscurePassword = !_isObscurePassword;
              }
            });
          },
        ),
      ),
      validator: (value) {
        if (value!.length < 6) return "Password must be at least 6 characters";
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedActivity,
      decoration: InputDecoration(
        hintText: "Select business activity",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.business_center, color: Color(0xFF664187)),
      ),
      items: activityOptions.map((activity) {
        return DropdownMenuItem(
          value: activity,
          child: Text(activity),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedActivity = value!;
        });
      },
      validator: (value) =>
          value == null ? "Please select a business activity" : null,
    );
  }

  Widget _buildSignupButton() {
    return Center(
      child: SizedBox(
        width: 300,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (passwordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Passwords do not match")),
                );
                return;
              }
              _registerOwner();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF53336F),
            padding: EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            "Sign up",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, "/login");
                },
            ),
          ],
        ),
      ),
    );
  }
}
