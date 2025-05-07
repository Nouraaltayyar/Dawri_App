import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_details_page.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  // Load the user's email from SharedPreferences
  Future<void> _loadUserEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');

      print("Loaded email from SharedPreferences: $email");

      setState(() {
        userEmail = email;
        isLoading = false; // Set isLoading to false after email is loaded
      });

      if (userEmail == null) {
        print("No email found in SharedPreferences.");
      } else {
        print("User email loaded successfully: $userEmail");
      }
    } catch (e) {
      print("Error loading email from SharedPreferences: $e");
    }
  }

  // Clear user notifications from Firestore
  Future<void> _clearUserNotifications() async {
    if (userEmail == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('email', isEqualTo: userEmail)
          .get();

      print("Fetched ${snapshot.docs.length} notifications from Firestore.");

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print("Error clearing notifications from Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Show loading indicator while loading the user's email
      return Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
          backgroundColor: Color(0xFFC19DDA),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userEmail == null) {
      // If the userEmail is null, show a message to prompt them
      return Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
          backgroundColor: Color(0xFFC19DDA),
        ),
        body: Center(child: Text("No user email found")),
      );
    }

    // Main screen when email is loaded and notifications are ready
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC19DDA),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFF53336F)),
            onPressed: () async {
              await _clearUserNotifications();
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('email', isEqualTo: userEmail)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Log waiting status
            print("Waiting for Firestore data...");
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error fetching data from Firestore: ${snapshot.error}");
            return Center(child: Text("Error fetching notifications"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // Log if there is no data or empty data
            print("No notifications found in Firestore.");
            return Center(child: Text("No notifications yet"));
          }

          final docs = snapshot.data!.docs;

          print("Loaded ${docs.length} notifications from Firestore.");

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              String title = data['title'] ?? 'No title';
              String body = data['body'] ?? 'No body';
              String email = data['email'] ?? 'No email';
              Timestamp? createdAt = data['created_at'];

              String createdAtString = createdAt != null
                  ? createdAt.toDate().toString()
                  : 'Unknown time';

              // Debugging - print each notification data
              print(
                  "Notification $index - Title: $title, Body: $body, CreatedAt: $createdAtString");

              return Card(
                color: Colors.white,
                elevation: 6,
                shadowColor: Color(0xFF53336F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.notifications_active,
                      color: Color(0xFF53336F)),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF53336F),
                    ),
                  ),
                  subtitle: Text(body),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailsPage(
                          title: title,
                          body: body,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
