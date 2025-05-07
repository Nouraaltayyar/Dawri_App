import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dawri_app/admin/AdminQueuesPage.dart';

class CategoryView extends StatefulWidget {
  final String category;

  const CategoryView({super.key, required this.category});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  List<Map<String, dynamic>> locations = [];
  String selectedCity = 'All';
  Map<String, bool> hasReservations = {};

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('category', isEqualTo: widget.category)
        .get();

    final locationsList = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();

    for (var location in locationsList) {
      final reservations = await FirebaseFirestore.instance
          .collection('reservations')
          .where('locationId', isEqualTo: location['id'])
          .limit(1)
          .get();

      hasReservations[location['id']] = reservations.docs.isNotEmpty;
    }

    setState(() {
      locations = locationsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCity == 'All'
        ? locations
        : locations.where((loc) => loc['city'] == selectedCity).toList();

    final cities = {'All', ...locations.map((e) => e['city'] ?? '')};

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButton<String>(
            value: selectedCity,
            isExpanded: true,
            onChanged: (value) {
              setState(() => selectedCity = value!);
            },
            items: cities.map((city) {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final place = filtered[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(place['name'] ?? 'No Name'),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(place['city'] ?? ''),
                      Icon(
                        Icons.circle,
                        color: (hasReservations[place['id']] ?? false)
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminQueuesPage(place: place),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
