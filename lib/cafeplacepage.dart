import 'package:dawri_app/cafepage.dart';
import 'package:flutter/material.dart';
import 'DetailsReview.dart';
import 'ReservPage.dart';

class cafeplacepage extends StatefulWidget {
  final Map<String, dynamic> location;

  const cafeplacepage({Key? key, required this.location}) : super(key: key);

  @override
  _PlacePageState createState() => _PlacePageState();
}

class _PlacePageState extends State<cafeplacepage> {
  @override
  Widget build(BuildContext context) {
    final location = widget.location;

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Icon(
                  Icons.coffee,
                  size: 100,
                  color: Colors.black.withOpacity(0.4), // أيقونة معتمة شوي
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              location['name'] ?? 'Cafe',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '📍 ${location['city'] ?? 'No address provided'}',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '🕒 ${location['from'] ?? '--'} - ${location['to'] ?? '--'}',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            DetailsReview(locationId: location['id']),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BookaTableButten(location: location),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String?> {
  List<String> searchTerms = [
    'Mocha Bliss Café',
    'Velvet Bean Coffee',
    'Golden Brew Lounge',
    'Caffeine Haven',
    'The Cozy Cup',
    'Maple Roast Café',
    'Sunrise Espresso',
    'Lush Latte House'
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final matchQuery = searchTerms
        .where((term) => term.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(matchQuery);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final matchQuery = searchTerms
        .where((term) => term.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(matchQuery);
  }

  Widget _buildList(List<String> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ListTile(title: Text(items[index])),
    );
  }
}

class BookaTableButten extends StatelessWidget {
  final Map<String, dynamic> location;

  const BookaTableButten({Key? key, required this.location}) : super(key: key);

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
        backgroundColor: const Color(0xFF53336F),
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
