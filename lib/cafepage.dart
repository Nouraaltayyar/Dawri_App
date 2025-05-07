import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cafeplacepage.dart';

class CafePage extends StatefulWidget {
  @override
  State<CafePage> createState() => _CafepageState();
}

class _CafepageState extends State<CafePage> {
  String selectedCity = 'All';
  List<Map<String, dynamic>> cafes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCafes();
  }

  Future<void> fetchCafes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('category', isEqualTo: 'Cafes')
        .get();

    final List<Map<String, dynamic>> fetched = snapshot.docs.map((doc) {
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
      cafes = fetched;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = selectedCity == 'All'
        ? cafes
        : cafes.where((c) => c['city'] == selectedCity).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text(
          'Available Cafes',
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
                delegate: CafeSearchDelegate(cafes),
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
                final cafe = filtered[index];
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
                          builder: (_) => cafeplacepage(location: cafe),
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
                              Icons.local_cafe,
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
                                  cafe['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF53336F),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  cafe['city'],
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

  String defaultImage(String name) {
    if (name.contains('Velvet')) {
      return 'https://images.pexels.com/photos/302895/pexels-photo-302895.jpeg';
    }
    return 'https://th.bing.com/th/id/OIP.gRpmc-_e1E7YIRdskjPJ0gHaFj?rs=1&pid=ImgDetMain';
  }
}

class CafeSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, dynamic>> cafes;
  CafeSearchDelegate(this.cafes);

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
    final results = cafes
        .where((c) => c['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return buildCafeList(results, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = cafes
        .where((c) => c['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return buildCafeList(suggestions, context);
  }

  Widget buildCafeList(List<Map<String, dynamic>> data, BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_, index) {
        final cafe = data[index];
        return ListTile(
          title: Text(cafe['name']),
          subtitle: Text(cafe['city']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => cafeplacepage(location: cafe),
              ),
            );
          },
        );
      },
    );
  }
}
