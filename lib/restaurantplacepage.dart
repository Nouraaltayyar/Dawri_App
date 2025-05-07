import 'package:flutter/material.dart';
import 'package:dawri_app/ReservPage.dart';

import 'DetailsReview.dart';

class RestaurantPlacePage extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantPlacePage({Key? key, required this.restaurant})
      : super(key: key);

  @override
  _RestaurantPlacePageState createState() => _RestaurantPlacePageState();
}

class _RestaurantPlacePageState extends State<RestaurantPlacePage> {
  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    String operatingHours = '';
    if (restaurant['from'] != null && restaurant['to'] != null) {
      operatingHours = '${restaurant['from']} - ${restaurant['to']}';
    } else {
      operatingHours = 'Not specified';
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          ),
          /* actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF53336F)),
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
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              restaurant['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '📍 ${restaurant['city'] ?? 'No address available'}',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '🕒 $operatingHours',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            DetailsReview(locationId: restaurant['id']),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BookaTableButten(
          restaurant: {
            'id': restaurant['id'],
            'name': restaurant['name'],
            'city': restaurant['city'],
            'from': restaurant['from'],
            'to': restaurant['to'],
            'image': restaurant['image'],
          },
        ),
      ),
    );
  }
}

class BookaTableButten extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const BookaTableButten({Key? key, required this.restaurant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReservPage(location: restaurant),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF53336F),
        padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Text(
        "Book now",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String?> {
  final List<String> searchTerms = [
    'Dana Restaurant',
    'Nora Restaurant',
    'Fatima Restaurant',
    'Kain Restaurant',
    'Fa Restaurant',
    'Jeem Restaurant',
    'Nara Organic Restaurant',
    'Al dente Restaurant',
  ];

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = searchTerms
        .where((restaurant) =>
            restaurant.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(results[index]),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = searchTerms
        .where((restaurant) =>
            restaurant.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(suggestions[index]),
        onTap: () {
          query = suggestions[index];
          showResults(context);
        },
      ),
    );
  }
}
