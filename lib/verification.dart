import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  VerifyCodeScreen({required this.email});

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  TextEditingController pinController = TextEditingController();
  late Timer _timer;
  int _secondsRemaining = 180; 
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
          _timer.cancel();
        });
      }
    });
  }

  void _resendCode() {
    if (_isResendEnabled) {
      setState(() {
        _secondsRemaining = 180;
        _isResendEnabled = false;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification code sent again!")),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

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
              Text(
                "Verification Code",
                style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "We've sent a 4-digit verification code to your email.\nPlease enter the code below to proceed",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 30),

              PinCodeTextField(
                appContext: context,
                length: 4,
                controller: pinController,
                keyboardType: TextInputType.number,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  activeFillColor: Color(0xffc19dda),
                  inactiveFillColor: Color(0xfff7efe7),
                  selectedFillColor: Colors.grey.withOpacity(0.2),
                  inactiveColor: Colors.purple,
                  activeColor: Colors.purple,
                  selectedColor: Color(0xffc19dda),
                ),
                enableActiveFill: true,
              ),
              
              SizedBox(height: 10),

              Text(
                "The verify code will expire in 0${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              SizedBox(height: 15),

              GestureDetector(
                onTap: _resendCode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: _isResendEnabled ? Colors.purple : Colors.grey),
                    SizedBox(width: 5),
                    Text(
                      "Resend Code",
                      style: TextStyle(
                        color: _isResendEnabled ? Colors.purple : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              Center(
                child: ElevatedButton(
                  onPressed: () { 
                    Navigator.pushNamed(context, "/new_password"); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFc19dda),
                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Confirm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}