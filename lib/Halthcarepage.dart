import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'healthcareplacepage.dart';

class Halthcarepage extends StatefulWidget {
  @override
  State<Halthcarepage> createState() => _HalthcarepageState();
}

class _HalthcarepageState extends State<Halthcarepage> {
  String selectedCity = 'All';
  List<Map<String, dynamic>> facilities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHealthcareFacilities();
  }

  Future<void> fetchHealthcareFacilities() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('category', isEqualTo: 'HealthCare facilities')
        .get();

    final fetched = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'city': data['city'] ?? '',
        'from': data['from'],
        'to': data['to'],
        'image': data['image'] ?? defaultImage(data['name']),
      };
    }).toList();

    setState(() {
      facilities = fetched;
      isLoading = false;
    });
  }

  String defaultImage(String name) {
    if (name.contains('Zahraa')) {
      return 'https://lh5.googleusercontent.com/p/AF1QipPvUuB1jlwu7QiNNqW-Ex82AqQsr8Jz-Gkq_x36=w408-h248-k-no';
    }
    return 'https://th.bing.com/th/id/OIP.gRpmc-_e1E7YIRdskjPJ0gHaFj?rs=1&pid=ImgDetMain';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCity == 'All'
        ? facilities
        : facilities.where((f) => f['city'] == selectedCity).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text(
          'Available Healthcare',
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF53336F)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: HealthcareSearchDelegate(facilities),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final place = filtered[index];
                return Card(
                  color: Colors.white,
                  elevation: 6,
                  shadowColor: Color(0xFF53336F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HealthcarePlacePage(location: place),
                        ),
                      );
                    },
                    child: Container(
                      height: 130,
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Color(0xFFF3E5F5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.local_hospital,
                              size: 50,
                              color: Color(0xFF53336F),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  place['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF53336F),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  place['city'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFC19DDA),
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: selectedCity,
                items: <String>[
                  'All',
                  'Dammam',
                  'Hafer Al Batin',
                  'Qatif',
                  'Riyadh'
                ]
                    .map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value!;
                  });
                },
                underline: Container(),
                icon: Icon(Icons.arrow_drop_down, color: Color(0xFF53336F)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthcareSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, dynamic>> facilities;
  HealthcareSearchDelegate(this.facilities);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = facilities
        .where((f) => f['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(results, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = facilities
        .where((f) => f['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(suggestions, context);
  }

  Widget _buildList(List<Map<String, dynamic>> items, BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, index) {
        final place = items[index];
        return ListTile(
          title: Text(place['name']),
          subtitle: Text(place['city']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HealthcarePlacePage(location: place),
              ),
            );
          },
        );
      },
    );
  }
}
