import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UpdatePage extends StatefulWidget {
  final String reservationId;

  const UpdatePage({super.key, required this.reservationId});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? selectedValue;
  double value = 1;

  @override
  void initState() {
    super.initState();
    _loadReservation();
  }

  void _loadReservation() async {
    final doc = await FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservationId)
        .get();

    final data = doc.data();
    if (data != null) {
      setState(() {
        _dateController.text = data['date'] ?? '';
        _timeController.text = data['time'] ?? '';
        value = (data['companions'] ?? 1).toDouble();
        selectedValue = data['specialCase'] == true ? 'option1' : 'option2';
      });
    }
  }

  Future<void> _submitUpdate() async {
    final updateData = {
      'date': _dateController.text,
      'time': _timeController.text,
      'companions': value.toInt(),
      'specialCase': selectedValue == 'option1',
    };

    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservationId)
        .update(updateData);

    showConfirmationAlert();
  }

  void showConfirmationAlert() {
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
            'Your Reservation has been successfully Updated!',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      buttons: [
        DialogButton(
          child: Text(
            'Back to Reservation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Color(0xFF53336F),
        ),
      ],
    ).show();
  }

  void showValidationAlert(String missingFields) {
    Alert(
      context: context,
      title: 'Incomplete Information',
      desc: 'Please ensure you have selected: $missingFields',
      closeIcon: Icon(Icons.close),
      buttons: [
        DialogButton(
          child: Text(
            'Okay',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
          color: Color(0xFF53336F),
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color(0xFFF7EFE5),
      appBar: AppBar(
        title: Text(
          "",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        //backgroundColor: Color(0xFFF7EFE5),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF53336F)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("What Would You Like to Update?", style: _headerStyle()),
            SizedBox(height: 20),
            Text("Reservation Date", style: _headerStyle()),
            _buildDateField(),
            SizedBox(height: 20),
            Text("Time", style: _headerStyle()),
            _buildTimeField(),
            SizedBox(height: 20),
            Text("Companions", style: _headerStyle()),
            _buildSpinBox(),
            SizedBox(height: 30),
            Text(
              "Is there a special case?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _buildRadio("Yes", "option1"),
            _buildRadio("No", "option2"),
            SizedBox(height: 40),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Select the date",
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_month),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              _dateController.text = DateFormat("dd-MM-yyyy").format(date);
            }
          },
        ),
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(width: 4),
      ),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Select the time",
        suffixIcon: IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (time != null) {
              _timeController.text = time.format(context);
            }
          },
        ),
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(width: 4),
      ),
    );
  }

  Widget _buildSpinBox() {
    return SpinBox(
      min: 1,
      max: 20,
      value: value,
      onChanged: (v) => value = v,
      decoration: InputDecoration(
        enabledBorder: _borderStyle(),
        focusedBorder: _borderStyle(width: 4),
      ),
    );
  }

  Widget _buildRadio(String title, String val) {
    return RadioListTile<String>(
      title: Text(title),
      value: val,
      groupValue: selectedValue,
      onChanged: (value) => setState(() => selectedValue = value),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        List<String> missing = [];
        if (_dateController.text.isEmpty) missing.add("Date");
        if (_timeController.text.isEmpty) missing.add("Time");
        if (value < 1) missing.add("Companions");
        if (selectedValue == null) missing.add("Special Case");

        if (missing.isEmpty) {
          _submitUpdate();
        } else {
          showValidationAlert(missing.join(", "));
        }
      },
      child: Text(
        "Apply Changes",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF53336F),
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  OutlineInputBorder _borderStyle({double width = 5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Color(0xFFC19DDA), width: width),
    );
  }

  TextStyle _headerStyle() =>
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
}
