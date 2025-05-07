import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'eventplacepage.dart';

class EventPage extends StatefulWidget {
  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String selectedCity = 'All';
  List<Map<String, dynamic>> allEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventsFromFirestore();
  }

  Future<void> fetchEventsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('category', isEqualTo: 'Events')
        .get();

    final List<Map<String, dynamic>> fetched = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'city': data['city'] ?? '',
        'from': data['from'],
        'to': data['to'],
        'image': data['image'] ?? defaultEventImage(data['name']),
      };
    }).toList();

    setState(() {
      allEvents = fetched;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = selectedCity == 'All'
        ? allEvents
        : allEvents.where((e) => e['city'] == selectedCity).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text(
          'Available Events',
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
                delegate: EventSearchDelegate(allEvents),
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
                final event = filtered[index];
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
                          builder: (_) => EventPlacePage(location: event),
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
                              Icons.event,
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
                                  event['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF53336F),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  event['city'],
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

  String defaultEventImage(String name) {
    if (name.contains('Riyadh')) {
      return 'https://houseofsaud.com/wp-content/uploads/2023/02/Riyadh-season-2022.jpg';
    }
    return 'https://th.bing.com/th/id/OIP.xon0XNNgDOQnBqmlQDsjgAHaFN?rs=1&pid=ImgDetMain';
  }
}

class EventSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, dynamic>> allEvents;

  EventSearchDelegate(this.allEvents);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = allEvents
        .where((event) =>
            event['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(results, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allEvents
        .where((event) =>
            event['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(suggestions, context);
  }

  Widget _buildList(List<Map<String, dynamic>> data, BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (_, index) {
        final event = data[index];
        return ListTile(
          title: Text(event['name']),
          subtitle: Text(event['city']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventPlacePage(location: event),
              ),
            );
          },
        );
      },
    );
  }
}
