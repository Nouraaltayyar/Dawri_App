import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "About Us",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dawri App",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Dawri is an innovative app that allows users to reserve their spot in a queue, track their position, and know who's ahead of them in real time.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Divider(),
            Text(
              "Contact Us",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.email, color: Color(0xFF53336F)),
                SizedBox(width: 10),
                Text("support@dawri.com"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.web, color: Color(0xFF53336F)),
                SizedBox(width: 10),
                Text("www.dawri.com"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
