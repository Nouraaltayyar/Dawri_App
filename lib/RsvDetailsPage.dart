import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RsvDetailsPage extends StatefulWidget {
  final String reservationId;

  const RsvDetailsPage({Key? key, required this.reservationId})
      : super(key: key);

  @override
  _RsvDetailsPageState createState() => _RsvDetailsPageState();
}

class _RsvDetailsPageState extends State<RsvDetailsPage> {
  Map<String, dynamic>? reservationData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReservationDetails();
  }

  Future<void> fetchReservationDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId)
          .get();

      if (doc.exists) {
        setState(() {
          reservationData = doc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching reservation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "",
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : reservationData == null
              ? Center(child: Text('Reservation not found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailRow(
                          'Restaurant', reservationData!['restaurantName']),
                      detailRow('City', reservationData!['city']),
                      detailRow('Date', reservationData!['date']),
                      detailRow('Time', reservationData!['time']),
                      detailRow('Companions',
                          reservationData!['companions'].toString()),
                      detailRow('Special Case',
                          reservationData!['specialCase'] ? 'Yes' : 'No'),
                    ],
                  ),
                ),
    );
  }

  Widget detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
