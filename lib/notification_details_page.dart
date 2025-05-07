import 'package:flutter/material.dart';

class NotificationDetailsPage extends StatelessWidget {
  final String title;
  final String body;

  NotificationDetailsPage({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Color(0xFFC19DDA)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(body, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
