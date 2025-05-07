import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:group_button/group_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});

  @override
  _FeedBackPageState createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final TextEditingController _textformController = TextEditingController();
  final GroupButtonController _groupController = GroupButtonController();
  double _rating = 3.0;

  final List<String> issuesOptions = [
    "Slow Loading",
    "Application Bugs",
    "Customer Service",
    "Weak Functionality",
    "Other Problems"
  ];

  void _submitFeedback() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? "Anonymous";
    final selectedIssues = _groupController.selectedIndexes
        .map((index) => issuesOptions[index])
        .toList();

    final feedbackData = {
      'email': email,
      'rating': _rating,
      'selectedIssues': selectedIssues,
      'notes': _textformController.text,
      'timestamp': DateTime.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('feedback').add(feedbackData);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ), //Color(0xFF53336F),
              //size: 80),
              SizedBox(height: 15),
              Text("Feedback Sent!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF53336F),
                    minimumSize: Size(200, 50)),
              ),
            ],
          ),
        ),
      );

      _textformController.clear();
      _groupController.unselectAll();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send feedback.' + e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text(
          "Feedback",
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("How Was Your Overall\n Experience?",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF53336F))),
            SizedBox(height: 10),
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) =>
                    Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => setState(() => _rating = rating),
              ),
            ),
            SizedBox(height: 20),
            Text("What is Wrong?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                )),
            GroupButton(
              controller: _groupController,
              buttons: issuesOptions,
              isRadio: false,
              buttonBuilder: (selected, value, context) => Container(
                  width: 180,
                  height: 45,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  )),
            ),
            SizedBox(height: 20),
            Text("Notes",
                //textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                )),
            TextFormField(
              controller: _textformController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "How can we do better?",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
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
    );
  }
}
