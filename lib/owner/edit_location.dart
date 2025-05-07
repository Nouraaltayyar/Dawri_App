import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class edit_location extends StatefulWidget {
  @override
  _EditlocationState createState() => _EditlocationState();
}

class _EditlocationState extends State<edit_location> {
  String? selectedLocation;
  String? selectedCities;
  String? selectedcategory;
  TimeOfDay fromTime = TimeOfDay.now();
  TimeOfDay toTime = TimeOfDay.now();

  List<Map<String, dynamic>> userLocations = [];
  String? selectedLocationId;

  @override
  void initState() {
    super.initState();
    _fetchUserLocations();
  }

  Future<void> _fetchUserLocations() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('ownerId', isEqualTo: uid)
        .get();

    setState(() {
      userLocations = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'city': doc['city'],
          'category': doc['category'],
          'from': doc['from'] ?? '',
          'to': doc['to'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> _updateLocation() async {
    if (selectedLocationId == null) return;

    await FirebaseFirestore.instance
        .collection('locations')
        .doc(selectedLocationId)
        .update({
      'city': selectedCities,
      'category': selectedcategory,
      'from': fromTime.format(context),
      'to': toTime.format(context),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location updated successfully")),
    );
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
          'Edit Location',
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
            _buildDropdown(
              hint: "Choose location",
              value: selectedLocation,
              items: userLocations.map((loc) => loc['name'] as String).toList(),
              onChanged: (value) {
                final selected =
                    userLocations.firstWhere((loc) => loc['name'] == value);
                setState(() {
                  selectedLocation = value;
                  selectedLocationId = selected['id'];
                  selectedCities = selected['city'];
                  selectedcategory = selected['category'];
                });
              },
            ),
            SizedBox(height: 20),
            _buildDropdown(
              hint: "Choose city",
              value: selectedCities,
              items: ['Qatif', 'Dammam', 'Hafer Al Batin'],
              onChanged: (value) => setState(() => selectedCities = value),
            ),
            SizedBox(height: 20),
            _buildDropdown(
              hint: "Choose category",
              value: selectedcategory,
              items: [
                'cafes',
                'Restaurants',
                'Banks',
                'HealthCare ',
                'Events',
              ],
              onChanged: (value) => setState(() => selectedcategory = value),
            ),
            SizedBox(height: 20),
            _buildLabel('Opening Hours'),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'From: ${fromTime.format(context)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'To: ${toTime.format(context)}',
                      style: TextStyle(fontSize: 16),
                    ),
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
                  onPressed: _updateLocation,
                  child: Text(
                    'Update',
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
