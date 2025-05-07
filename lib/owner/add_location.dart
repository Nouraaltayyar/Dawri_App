import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddLocation extends StatefulWidget {
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedCity;
  String? selectedCategory;
  TimeOfDay fromTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay toTime = TimeOfDay(hour: 17, minute: 0); // وقت الانتهاء

  Future<void> addNewLocation() async {
    String locationName = locationController.text.trim();
    String details = detailsController.text.trim();

    if (locationName.isEmpty ||
        selectedCity == null ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    String ownerId = _auth.currentUser!.uid;

    await _firestore.collection('locations').add({
      'name': locationName,
      'details': details, // إضافة التفاصيل هنا
      'ownerId': ownerId,
      'city': selectedCity,
      'category': selectedCategory,
      'from': fromTime.format(context),
      'to': toTime.format(context), // إضافة وقت النهاية
      'createdAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location added successfully')),
    );

    locationController.clear();
    detailsController.clear();
    setState(() {
      selectedCity = null;
      selectedCategory = null;
      fromTime = TimeOfDay(hour: 9, minute: 0);
      toTime = TimeOfDay(hour: 17, minute: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Location',
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildLabel('Please Enter Your Location Name Here'),
            _buildTextField(locationController, 'Enter your location here'),
            SizedBox(height: 16),
            _buildLabel('Details'),
            _buildTextField(
                detailsController, 'Enter more details about this location'),
            SizedBox(height: 16),
            _buildLabel('Chose City'),
            _buildDropdown(
              value: selectedCity,
              items: ['Qatif', 'Dammam', 'Hafer Al Batin'],
              hint: 'List of cities',
              onChanged: (val) => setState(() => selectedCity = val),
            ),
            SizedBox(height: 16),
            _buildLabel('Category'),
            _buildDropdown(
              value: selectedCategory,
              items: [
                'Cafes',
                'Restaurants',
                'Banks',
                'HealthCare facilities',
                'Events',
              ],
              hint: 'List of categories',
              onChanged: (val) => setState(() => selectedCategory = val),
            ),
            SizedBox(height: 16),
            _buildLabel('Opening Hours'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: fromTime,
                    );
                    if (picked != null) {
                      setState(() => fromTime = picked);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    'From: ${fromTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: toTime,
                    );
                    if (picked != null) {
                      setState(() => toTime = picked);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    'To: ${toTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF53336F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: addNewLocation,
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(1, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(1, 2),
            blurRadius: 4,
          )
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: SizedBox(),
        hint: Text(hint),
        onChanged: onChanged,
        items: items
            .map((val) => DropdownMenuItem(
                  value: val,
                  child: Text(val),
                ))
            .toList(),
      ),
    );
  }
}
