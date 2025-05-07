import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/auth_services.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  String? selectedValue;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _registerUser() async {
    try {
      UserCredential userCredential = await AuthService().signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await DatabaseService().createUserIfNotExists(
        uid: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        birthDate: dateController.text.trim(),
        hasDisability: selectedValue == 'option1',
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
                SizedBox(height: 40),
                Text(
                  "Let's get to know you",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Enter your personal information then answer the question below.",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                SizedBox(height: 30),
                _buildTextField(
                  controller: nameController,
                  hint: "Enter your name",
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? "Name cannot be empty" : null,
                ),
                SizedBox(height: 15),
                _buildDateField(context),
                SizedBox(height: 15),
                _buildTextField(
                  controller: phoneController,
                  hint: "Enter your phone number",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.length < 10 ? "Enter a valid phone number" : null,
                ),
                SizedBox(height: 15),
                _buildTextField(
                  controller: emailController,
                  hint: "Enter your email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      !value!.contains('@') ? "Enter a valid email" : null,
                ),
                SizedBox(height: 15),
                _buildPasswordField(passwordController, "Enter your password"),
                SizedBox(height: 15),
                _buildPasswordField(
                    confirmPasswordController, "Confirm Password"),
                SizedBox(height: 20),
                Text(
                  "Do you identify as a person with a disability?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildRadioTile("Yes", "option1"),
                _buildRadioTile("No", "option2"),
                SizedBox(height: 20),
                _buildLoginLink(context),
                SizedBox(height: 20),
                _buildSignupButton(),
                SizedBox(height: 40),
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

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: dateController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Enter your date of birth",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: Color(0xFF664187)),
          onPressed: () => _selectDate(context),
        ),
      ),
      validator: (value) => value!.isEmpty ? "Please select a date" : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      obscureText: _isObscurePassword,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.lock, color: Color(0xFF664187)),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isObscurePassword = !_isObscurePassword;
            });
          },
        ),
      ),
      validator: (value) =>
          value!.length < 6 ? "Password must be at least 6 characters" : null,
    );
  }

  Widget _buildRadioTile(String text, String value) {
    return RadioListTile<String>(
      title: Text(text),
      value: value,
      groupValue: selectedValue,
      onChanged: (value) {
        setState(() {
          selectedValue = value;
        });
      },
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
                color: Colors.purple,
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

  Widget _buildSignupButton() {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (passwordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Passwords do not match")),
                );
                return;
              }
              _registerUser();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFc19dda),
            padding: EdgeInsets.symmetric(vertical: 15),
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
}
