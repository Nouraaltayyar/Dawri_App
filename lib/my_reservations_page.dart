import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'CReservPage.dart';
import 'ReservPage.dart';
import 'UpdatePage.dart';
import 'RatePage.dart';
import 'RsvDetailsPage.dart';

class MyReservationsPage extends StatefulWidget {
  @override
  _MyReservationsPageState createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text(
          "Reservations",
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservations')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final reservations = snapshot.data!.docs;

          if (reservations.isEmpty) {
            return Center(child: Text("No reservations yet."));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final data = reservations[index].data() as Map<String, dynamic>;
              final docId = reservations[index].id;

              final name = data['restaurantName'] ?? 'Unknown';
              final city = data['city'] ?? 'Unknown';
              final date = data['date'] ?? '';
              final time = data['time'] ?? '';
              final companions = data['companions'] ?? 1;
              final canceled = data['canceled'] == true;

              final now = DateTime.now();
              DateTime? reservationDT;
              try {
                reservationDT =
                    DateFormat("dd-MM-yyyy h:mm a").parse("$date $time");
              } catch (_) {}

              final completed =
                  reservationDT != null && now.isAfter(reservationDT);
              final statusText = canceled
                  ? "Canceled"
                  : completed
                      ? "Completed"
                      : "Upcoming";
              final statusColor = canceled
                  ? Colors.red
                  : completed
                      ? Colors.green
                      : Colors.blue;

              final location = {
                "name": name,
                "city": city,
              };

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5), blurRadius: 5)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                              color: statusColor, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),

                    SizedBox(height: 8),
                    Text('$time  •  $companions Guests'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Always show Details
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RsvDetailsPage(reservationId: docId),
                        ),
                      ),
                      icon: Icon(Icons.info_outline, color: Colors.white),
                      label: Text("Details",
                          style: TextStyle(color: Colors.white)),
                      style: _btnStyle(),
                    ),
                    SizedBox(height: 6),

                    if (canceled)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ReservPage(location: location)),
                          ),
                          icon: Icon(Icons.replay, color: Colors.white),
                          label: Text("Book Again",
                              style: TextStyle(color: Colors.white)),
                          style: _btnStyle(),
                        ),
                      )
                    else if (completed)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      RatePage(reservationId: docId)),
                            ),
                            icon: Icon(Icons.thumb_up, color: Colors.white),
                            label: Text("Rate",
                                style: TextStyle(color: Colors.white)),
                            style: _btnStyle(),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ReservPage(location: location)),
                            ),
                            icon: Icon(Icons.replay, color: Colors.white),
                            label: Text("Book Again",
                                style: TextStyle(color: Colors.white)),
                            style: _btnStyle(),
                          ),
                        ],
                      )
                    else // Upcoming
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      UpdatePage(reservationId: docId)),
                            ),
                            icon: Icon(Icons.edit_note, color: Colors.white),
                            label: Text("Update",
                                style: TextStyle(color: Colors.white)),
                            style: _btnStyle(),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            CReservPage(reservationId: docId)),
                                  ),
                              icon: Icon(Icons.cancel, color: Colors.white),
                              label: Text("Cancel",
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  minimumSize: Size(140, 40))),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF53336F),
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(140, 40));
  }
}
