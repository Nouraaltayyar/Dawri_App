import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'RsvDetailsPage.dart';

class RatePage extends StatefulWidget {
  final String reservationId;

  const RatePage({super.key, required this.reservationId});

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  double _rating = 3.0;
  final TextEditingController _notesController = TextEditingController();
  String? _locationId;

  @override
  void initState() {
    super.initState();
    _fetchLocationId();
  }

  Future<void> _fetchLocationId() async {
    final doc = await FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservationId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _locationId = data?['locationId'];
      });
    }
  }

  Future<void> _submitRating() async {
    if (_locationId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must be logged in to submit a review.")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'locationId': _locationId,
        'userId': user.uid,
        'rating': _rating,
        'notes': _notesController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Thank you for your rating!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RsvDetailsPage(reservationId: widget.reservationId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send rating: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
        ),
      ),
      body: _locationId == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "How Was Your Overall Experience?",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Rate this place",
                    style: TextStyle(fontSize: 27),
                  ),
                  SizedBox(height: 20),
                  RatingBar.builder(
                    initialRating: _rating,
                    minRating: 0.5,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 52,
                    itemBuilder: (context, _) =>
                        Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Notes",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _notesController,
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: "Write Your Review",
                      hintStyle: TextStyle(color: Color(0xFFC19DDA)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF53336F),
                      padding:
                          EdgeInsets.symmetric(horizontal: 150, vertical: 13),
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
    );
  }
}
