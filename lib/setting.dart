import 'package:flutter/material.dart';

class setting extends StatelessWidget {
  @override
  String supportNo = "11112345678";

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Color(0xFFC19DDA),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Color(0xFF53336F), size: 30),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName("/home"));
                    },
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.settings, color: Color(0xFF53336F), size: 30),
                  SizedBox(width: 10),
                  Text(
                    "SETTINGS",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    buildMenuItem(
                      Icons.person,
                      "My account",
                      context,
                      '/AccountUserr',
                      isUserAccount: true,
                    ),
                    buildMenuItem(
                        Icons.support_agent, "Support", context, '/support',
                        isSupport: true),
                    buildMenuItem(
                        Icons.info, "About us", context, '/AboutPage'),
                    buildMenuItem(
                        Icons.feedback, "Feedback", context, '/feedback'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Call Support"),
          content: Text("Do you want to call $supportNo?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Call", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget buildMenuItem(
    IconData icon,
    String title,
    BuildContext context,
    String route, {
    bool isSupport = false,
    bool isUserAccount = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Color(0xFFDBB6E6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF53336F)),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: Icon(Icons.arrow_forward, color: Color(0xFF53336F)),
        onTap: () {
          if (isSupport) {
            _showCallDialog(context);
          } else if (isUserAccount) {
            // tesssttttt i'll delete the test
            Navigator.pushNamed(
              context,
              route,
              arguments: {
                'name': 'Noura', // test
                'dob': '04/03/2002',
                'phone': '123456789',
                'email': 'Noura@example.com',
              },
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
