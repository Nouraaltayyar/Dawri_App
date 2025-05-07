import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawri_app/owner/OwnerQueuesPage.dart';
import 'package:dawri_app/owner/add_location.dart';
import 'package:dawri_app/owner/edit_location.dart';
import 'package:flutter/material.dart';
import 'package:dawri_app/owner/OwnerAccountPage.dart';
import 'package:dawri_app/owner/controlPnal.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerPage extends StatefulWidget {
  @override
  _OwnerPageState createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  String? userName = "Owner";
  int _currentIndex = 0;
  List<Map<String, dynamic>> ownerLocations = [];
  bool isLoading = true;

  final Map<String, IconData> categoryIcons = {
    'Cafe': Icons.local_cafe,
    'Restaurant': Icons.restaurant,
    'Bank': Icons.account_balance,
    'Health': Icons.local_hospital,
    'Event': Icons.event,
  };

  @override
  void initState() {
    super.initState();
    _loadOwnerLocations();
  }

  Future<void> _loadOwnerLocations() async {
    setState(() {
      isLoading = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final locationSnapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('ownerId', isEqualTo: uid)
        .get();

    List<Map<String, dynamic>> loaded = [];

    for (var loc in locationSnapshot.docs) {
      final locData = loc.data();

      final reservations = await FirebaseFirestore.instance
          .collection('reservations')
          .where('locationId', isEqualTo: loc.id)
          .limit(1)
          .get();

      final hasUsersInQueue = reservations.docs.isNotEmpty;

      loaded.add({
        'id': loc.id,
        'name': locData['name'] ?? '',
        'city': locData['city'] ?? '',
        'category': locData['category'] ?? '',
        'time': "${locData['from'] ?? ''} - ${locData['to'] ?? ''}",
        'hasUsersInQueue': hasUsersInQueue,
      });
    }

    setState(() {
      ownerLocations = loaded;
      isLoading = false;
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        endDrawer: Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 25),
                color: Color(0xFFC19DDA),
                child: Column(
                  children: [
                    SizedBox(height: 20),
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
              _buildDrawerItem(
                  Icons.home, "Home", () => Navigator.pop(context)),
              _buildDrawerItem(Icons.account_circle, "Account", () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => OwnerAccountPage()));
              }),
              _buildDrawerItem(Icons.settings, "Control Panel", () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => controlPanel()));
              }),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.redAccent),
                title: Text("Logout"),
                onTap: _logout,
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Color(0xFFC19DDA),
          title: Text(
            'Owner Home',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF53336F),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Color(0xFF53336F),
            unselectedLabelColor: Colors.black12,
            indicatorColor: Color(0xFF53336F),
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: "Locations"),
              Tab(text: "Queues"),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _loadOwnerLocations,
                    color: Color(0xFF53336F),
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: ownerLocations.length,
                      itemBuilder: (context, index) {
                        final location = ownerLocations[index];
                        final category = location['category'];
                        final categoryIcon = categoryIcons[category];

                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.white,
                          elevation: 7,
                          child: ListTile(
                            leading: categoryIcon != null
                                ? Icon(categoryIcon, color: Color(0xFF53336F))
                                : Icon(Icons.location_on,
                                    color: Color(0xFF53336F)),
                            title: Text(
                              location['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(location['city']),
                                Text(location['category']),
                                Text(location['time']),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => edit_location()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF53336F),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: Size(80, 40),
                              ),
                              child: Text(
                                'Edit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: _loadOwnerLocations,
                    color: Color(0xFF53336F),
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: ownerLocations.length,
                      itemBuilder: (context, index) {
                        final place = ownerLocations[index];
                        final hasUsersInQueue =
                            place['hasUsersInQueue'] ?? false;

                        return Card(
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.white,
                          elevation: 7,
                          child: ListTile(
                            leading:
                                Icon(Icons.queue, color: Color(0xFF53336F)),
                            title: Text(
                              place['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Click to view queue details"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 8,
                                  backgroundColor: hasUsersInQueue
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                SizedBox(height: 6),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OwnerQueuesPage(place: place),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddLocation()),
            );
          },
          backgroundColor: Color(0xFF53336F),
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Color(0XFF664187)),
          title: Text(title),
          onTap: onTap,
        ),
        Divider(),
      ],
    );
  }
}
