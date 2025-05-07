import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'restaurantplacepage.dart';

class RestaurantPage extends StatefulWidget {
  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  String selectedCity = 'All';
  List<Map<String, dynamic>> allRestaurants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantsFromFirestore();
  }

  Future<void> _fetchRestaurantsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('category', isEqualTo: 'Restaurants')
        .get();

    List<Map<String, dynamic>> fetched = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'city': data['city'] ?? '',
        'cuisine': data['cuisine'] ?? 'Unknown',
        'from': data['from'],
        'to': data['to'],
        'image': getImageForRestaurant(data['name']),
      };
    }).toList();

    setState(() {
      allRestaurants = fetched;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered = selectedCity == 'All'
        ? allRestaurants
        : allRestaurants
            .where((place) => place['city'] == selectedCity)
            .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text(
          "Available Restaurants",
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF53336F)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(allRestaurants),
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
                          builder: (context) =>
                              RestaurantPlacePage(restaurant: place),
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
                              Icons.restaurant,
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
                                  '${place['city']} - ${place['cuisine']}',
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
                items: <String>['All', 'Dammam', 'Hafer Al Batin', 'Qatif']
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

  String getImageForRestaurant(String name) {
    switch (name) {
      case 'Dana Restaurant':
        return 'https://th.bing.com/th/id/OIP.OX6pK2OmEFpeJrfkIZPBdgAAAA?rs=1&pid=ImgDetMain';
      case 'Nora Restaurant':
        return 'https://th.bing.com/th/id/R.a9c1aee27c759fe06074cfed415f30db?rik=meEv%2bfKbfopXnw&pid=ImgRaw&r=0';
      case 'Fatima Restaurant':
        return 'https://th.bing.com/th/id/OIP.-iWoEiuMSQomBJbw1t_yPAHaEc?rs=1&pid=ImgDetMain';
      case 'Kain Restaurant':
        return 'https://th.bing.com/th/id/OIP.lYpzWWbyjzy9lKFsURAgnwHaF7?rs=1&pid=ImgDetMain';
      case 'Fa Restaurantt':
        return 'https://th.bing.com/th/id/OIP.RqfSbn8Z8BkLmg_ZlHZMvAHaFj?rs=1&pid=ImgDetMain';
      case 'Nara Organic Restaurant':
        return 'https://th.bing.com/th/id/OIP.db8MCsRcmJxztCSf1FoWXwHaE7?w=2000&h=1333&rs=1&pid=ImgDetMain';
      case 'Jeem Restaurant':
        return 'https://th.bing.com/th/id/OIP.bAGppZh8Tp-tO-DWhRmy2gHaE7?rs=1&pid=ImgDetMain';
      default:
        return 'https://th.bing.com/th/id/OIP.gRpmc-_e1E7YIRdskjPJ0gHaFj?rs=1&pid=ImgDetMain';
    }
  }
}

class CustomSearchDelegate extends SearchDelegate<String?> {
  final List<Map<String, dynamic>> allRestaurants;

  CustomSearchDelegate(this.allRestaurants);

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
    final results = allRestaurants.where(
        (place) => place['name'].toLowerCase().contains(query.toLowerCase()));
    return _buildList(results.toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allRestaurants.where(
        (place) => place['name'].toLowerCase().contains(query.toLowerCase()));
    return _buildList(suggestions.toList());
  }

  Widget _buildList(List<Map<String, dynamic>> places) {
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
            title: Text(place['name']),
            subtitle: Text('${place['city']} - ${place['cuisine']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantPlacePage(restaurant: place),
                ),
              );
            });
      },
    );
  }
}
