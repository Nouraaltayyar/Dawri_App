import 'package:dawri_app/bankpage.dart';
import 'package:dawri_app/eventpage.dart';
import 'package:dawri_app/resturantPage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawri_app/services/database_service.dart';
import 'package:dawri_app/services/auth_services.dart';
import 'package:dawri_app/setting.dart';
import 'package:dawri_app/welcome.dart';
import 'Halthcarepage.dart';
import 'cafepage.dart';
import 'my_reservations_page.dart';
import 'notification_page.dart';
import 'RsvDetailsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int notificationCount = 0;
  String? userName;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> places = [
    {"image": "images/restaurant.png", "title": "Restaurants"},
    {"image": "images/Events.png", "title": "Events"},
    {"image": "images/HealthCare.png", "title": "Health Care"},
    {"image": "images/Cafes.png", "title": "Cafes"},
    {"image": "images/Banks.png", "title": "Banks"},
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationCountFromFirestore();
    fetchUserName();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _saveNotification(
        message.notification?.title ?? "No Title",
        message.notification?.body ?? "No Body",
      );
      _loadNotificationCountFromFirestore();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _saveNotification(
        message.notification?.title ?? "No Title",
        message.notification?.body ?? "No Body",
      );
      _loadNotificationCountFromFirestore();
    });
  }

  Future<void> fetchUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final name = await _dbService.getUserName(uid);
      setState(() {
        userName = name;
      });
    }
  }

  Future<void> _loadNotificationCountFromFirestore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('email', isEqualTo: email)
        .get();

    setState(() {
      notificationCount = snapshot.docs.length;
    });
  }

  Future<void> _saveNotification(String title, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedNotifications = prefs.getStringList('notifications');
    savedNotifications ??= [];
    savedNotifications.add("$title|$body");
    await prefs.setStringList('notifications', savedNotifications);
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Welcome()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text('HOME',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF53336F))),
        centerTitle: true,
        leading: Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: Color(0xFF53336F)),
              onPressed: () async {
                setState(() {
                  notificationCount = 0;
                });

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setInt('notificationCount', 0);
              },
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    notificationCount.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Color(0xFF53336F)),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 25),
              color: Color(0xFFC19DDA),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    alignment: Alignment.centerLeft,
                  ),
                  Text(
                    userName != null ? 'Welcome, $userName!' : 'Welcome!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF53336F),
                    ),
                  ),
                  Text(
                    "Menu",
                    style: TextStyle(fontSize: 16, color: Color(0xFF53336F)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFF53336F)),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Color(0xFF53336F)),
              title: Text("Reservations"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyReservationsPage(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Color(0xFF53336F)),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => setting()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.redAccent),
              title: Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "WELCOME TO DAWRI !",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              "where do you want to book?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 600,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  viewportFraction: 0.9,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: places.map((place) {
                  return GestureDetector(
                    onTap: () {
                      if (place["title"] == "Restaurants") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RestaurantPage()));
                      } else if (place["title"] == "Events") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventPage()));
                      } else if (place["title"] == "Health Care") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Halthcarepage()));
                      } else if (place["title"] == "Cafes") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CafePage()));
                      } else if (place["title"] == "Banks") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BankPage()));
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage(place["image"]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          color: Colors.black54,
                          width: double.infinity,
                          child: Text(
                            place["title"],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: places.asMap().entries.map((entry) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? Colors.purple[300]
                        : Colors.purple[100],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
