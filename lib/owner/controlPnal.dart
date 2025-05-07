import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_location.dart';
import 'add_location.dart';

class controlPanel extends StatefulWidget {
  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<controlPanel> {
  int availableTables = 0;
  int totalReservations = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final ownerId = _auth.currentUser?.uid;
    if (ownerId == null) return;

    try {
      QuerySnapshot locationsSnapshot = await _firestore
          .collection('locations')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      int tablesCount = 0;
      int totalReservationsCount = 0;

      for (var doc in locationsSnapshot.docs) {
        final locationId = doc.id;

        QuerySnapshot reservationsSnapshot = await _firestore
            .collection('reservations')
            .where('locationId', isEqualTo: locationId)
            .get();

        totalReservationsCount += reservationsSnapshot.size;
      }

      setState(() {
        availableTables = tablesCount;
        totalReservations = totalReservationsCount;
      });
    } catch (e) {
      print('Error loading control panel stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Control Panel',
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 50),
            buildMainButton('Add Location', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLocation()),
              );
            }),
            SizedBox(height: 20),
            buildMainButton('Edit Location', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => edit_location()),
              );
            }),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildStatItem("Available Tables", availableTables),
                  buildStatItem("Reservations", totalReservations),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMainButton(String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF53336F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF5D3D79),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: 70,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Text(
            count.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF53336F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
