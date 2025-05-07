import 'package:flutter/material.dart';
import 'DetailsReview.dart';
import 'ReservPage.dart';

class HealthcarePlacePage extends StatefulWidget {
  final Map<String, dynamic> location;

  const HealthcarePlacePage({Key? key, required this.location})
      : super(key: key);

  @override
  _HealthcarePlacePageState createState() => _HealthcarePlacePageState();
}

class _HealthcarePlacePageState extends State<HealthcarePlacePage> {
  @override
  Widget build(BuildContext context) {
    final location = widget.location;

    String operatingHours = '';
    if (location['from'] != null && location['to'] != null) {
      operatingHours = '${location['from']} - ${location['to']}';
    } else {
      operatingHours = '24/7';
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF664187),
            ),
          ),
          /*actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            ),
          ],*/
          backgroundColor: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Icon(
                  Icons.medical_services,
                  size: 100,
                  color: Colors.black.withOpacity(0.4), // أيقونة معتمة شوي
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              location['name'] ?? 'Healthcare Center',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '📍 ${location['city'] ?? 'Not specified'}',
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '🕒 $operatingHours',
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            DetailsReview(locationId: location['id']),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BookaTableButton(location: location),
      ),
    );
  }
}

class BookaTableButton extends StatelessWidget {
  final Map<String, dynamic> location;

  const BookaTableButton({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ReservPage(location: location)),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF664187),
        padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Text(
        "Book naw",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String?> {
  final List<String> searchTerms = [
    'King Faisal Specialist Hospital',
    'King Abdulaziz Medical City',
    'Al-Zahraa General Hospital',
    'Dr. Sulaiman Al Habib Medical Group',
  ];

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = searchTerms
        .where((term) => term.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searchTerms
        .where((term) => term.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(suggestions);
  }

  Widget _buildList(List<String> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(title: Text(items[index])),
    );
  }
}
