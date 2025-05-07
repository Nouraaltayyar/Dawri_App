import 'package:flutter/material.dart';

class Newpassword extends StatefulWidget {
  @override
  _NewpasswordState createState() => _NewpasswordState();
}

class _NewpasswordState extends State<Newpassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isObscurePassword = true; // تخلي كلمة المرور تبان او تطلع كدوت
  bool _isObscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Create New Password",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Please enter your new password here",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              _buildPasswordField(passwordController, "Enter your Password"),
              SizedBox(height: 15),
              _buildPasswordField(
                  confirmPasswordController, "Confirm Password"),
              SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, "/login"); // ربطتها بالهوم !!!!!!!!!!!!!
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFc19dda),
                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Reset",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: controller == passwordController
          ? _isObscurePassword
          : _isObscureConfirmPassword,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)), // نفس تنسيق تسجيل الدخول
        prefixIcon: Icon(Icons.lock, color: Color(0xFF664187)),
        suffixIcon: IconButton(
          icon: Icon(
            controller == passwordController
                ? (_isObscurePassword ? Icons.visibility_off : Icons.visibility)
                : (_isObscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (controller == passwordController) {
                _isObscurePassword = !_isObscurePassword;
              } else {
                _isObscureConfirmPassword = !_isObscureConfirmPassword;
              }
            });
          },
        ),
      ),
    );
  }
}
