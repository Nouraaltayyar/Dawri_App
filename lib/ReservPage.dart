import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'CReservPage.dart';
import 'RsvDetailsPage.dart';

class ReservPage extends StatefulWidget {
  final Map<String, dynamic> location;

  ReservPage({required this.location});

  @override
  _ReservPageState createState() => _ReservPageState();
}

class _ReservPageState extends State<ReservPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? selectedValue;
  double value = 1;

  void showConfirmationAlert(String reservationId) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: true,
        isOverlayTapDismiss: false,
        titleStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 100),
          SizedBox(height: 20),
          Text(
            'Thank You For Using Dawri!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Your Reservation has been successfully confirmed!',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            'View Reservation',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RsvDetailsPage(reservationId: reservationId),
              ),
            );
          },
          color: Color(0xFF53336f),
        ),
      ],
    ).show();
  }

  void showValidationAlert(String missingFields) {
    Alert(
      context: context,
      style: AlertStyle(
        isCloseButton: true,
        isOverlayTapDismiss: false,
        titleStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        children: [
          Icon(Icons.error, color: Colors.red, size: 100),
          SizedBox(height: 20),
          Text(
            'Incomplete Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Please ensure you have selected: $missingFields',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            'Okay',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color(0xFF53336f),
        )
      ],
    ).show();
  }

  Future<String?> submitReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final reservationData = {
      'userId': user.uid,
      'restaurantName': widget.location['name'] ?? 'Unknown',
      'city': widget.location['city'] ?? 'Unknown',
      'locationId': widget.location['id'],
      'date': _dateController.text,
      'time': _timeController.text,
      'companions': value.toInt(),
      'specialCase': selectedValue == "option1",
      'createdAt': FieldValue.serverTimestamp(),
      'canceled': false,
    };

    final docRef = await FirebaseFirestore.instance
        .collection('reservations')
        .add(reservationData);
    return docRef.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFF7EFE5),
      appBar: AppBar(
        title: Text("",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        //backgroundColor: Color(0xFFF7EFE5),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF53336F)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text("Reservation Date", style: headerStyle),
              SizedBox(height: 20),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: dateInputDecoration(() async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    _dateController.text =
                        DateFormat("dd-MM-yyyy").format(date);
                  }
                }, Icons.calendar_month, "Select the date"),
              ),
              SizedBox(height: 20),
              Text("Time", style: headerStyle),
              SizedBox(height: 20),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: dateInputDecoration(() async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    _timeController.text = time.format(context);
                  }
                }, Icons.access_time, "Select the time"),
              ),
              SizedBox(height: 20),
              Text("Companions", style: headerStyle),
              SizedBox(height: 20),
              SpinBox(
                min: 1,
                max: 20,
                value: value,
                onChanged: (newValue) => value = newValue,
                decoration: inputBorder(),
              ),
              SizedBox(height: 50),
              Text("Is there a special case?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              buildRadio("Yes", "option1"),
              buildRadio("No", "option2"),
              SizedBox(height: 75),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  actionButton("Cancel", () async {
                    final reservationId = await submitReservation();
                    if (reservationId != null) {
                      Navigator.pop(context);
                    }
                  }),
                  SizedBox(width: 20),
                  actionButton("Confirm", () async {
                    List<String> missing = [];
                    if (_dateController.text.isEmpty) missing.add("Date");
                    if (_timeController.text.isEmpty) missing.add("Time");
                    if (value < 1) missing.add("Companions");
                    if (selectedValue == null)
                      missing.add("Special Case Option");

                    if (missing.isNotEmpty) {
                      showValidationAlert(missing.join(", "));
                    } else {
                      final reservationId = await submitReservation();
                      if (reservationId != null) {
                        showConfirmationAlert(reservationId);
                      }
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRadio(String label, String valueOpt) {
    return RadioListTile<String>(
      title: Text(label),
      value: valueOpt,
      groupValue: selectedValue,
      onChanged: (value) => setState(() => selectedValue = value),
    );
  }

  InputDecoration dateInputDecoration(
      VoidCallback onPressed, IconData icon, String hint) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(20),
      suffixIcon: IconButton(onPressed: onPressed, icon: Icon(icon)),
      hintText: hint,
      enabledBorder: inputBorder().border,
      focusedBorder: inputBorder().border,
    );
  }

  InputDecoration inputBorder() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Color(0xFFC19DDA), width: 5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            BorderSide(color: Color.fromARGB(255, 155, 65, 173), width: 4),
      ),
    );
  }

  Widget actionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF53336f),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  TextStyle get headerStyle =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
}
