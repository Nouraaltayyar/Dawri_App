import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'RsvDetailsPage.dart';

class CReservPage extends StatefulWidget {
  final String reservationId;

  const CReservPage({Key? key, required this.reservationId}) : super(key: key);

  @override
  _CReservPageState createState() => _CReservPageState();
}

class _CReservPageState extends State<CReservPage> {
  final TextEditingController _otherReasonController = TextEditingController();
  List<String> selectedReasons = [];

  void showConfirmationAlert() {
    Alert(
      context: context,
      title: '',
      content: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 100),
          SizedBox(height: 10),
          Text(
            'Thank You For Using Dawri!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Your Reservation has been successfully Canceled!',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      closeIcon: Icon(Icons.close),
      buttons: [
        DialogButton(
          child: Text(
            'Back to Reservations',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RsvDetailsPage(reservationId: widget.reservationId),
              ),
            );
          },
          color: Color(0xFF53336F),
        )
      ],
    ).show();
  }

  Future<void> submitCancellationReason() async {
    List<String> reasons = [...selectedReasons];
    if (_otherReasonController.text.trim().isNotEmpty) {
      reasons.add(_otherReasonController.text.trim());
    }

    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservationId)
        .update({
      'canceled': true,
      'cancellationReasons': reasons,
      'canceledAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title:
            Text("Reservations", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Why Are You Canceling Your Reservation?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(height: 40),
              GroupButton(
                buttons: [
                  "Restaurant Choice",
                  "Changed Plans",
                  "Lack of Time",
                  "Inconvenient Location",
                ],
                isRadio: false,
                onSelected: (val, index, isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedReasons.add(val);
                    } else {
                      selectedReasons.remove(val);
                    }
                  });
                },
                buttonBuilder: (selected, value, context) {
                  return Container(
                      width: 180,
                      height: 45,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Color(0xFFC19DDA) : Color(0xFF53336F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFF53336F),
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          color: selected ? Color(0xFF53336F) : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ));
                },
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Other?",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _otherReasonController,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "...",
                  hintStyle: TextStyle(color: Color(0xFFC19DDA)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await submitCancellationReason();
                  showConfirmationAlert();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF53336F),
                  padding: EdgeInsets.symmetric(horizontal: 150, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: 'Telex',
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
