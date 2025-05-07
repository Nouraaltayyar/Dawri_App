import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'bankPlacePage.dart';

class BankPage extends StatefulWidget {
  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  String selectedCity = 'All';
  List<Map<String, dynamic>> allBanks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanksFromFirestore();
  }

  Future<void> _fetchBanksFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('locations')
        .where('category', isEqualTo: 'Banks')
        .get();

    List<Map<String, dynamic>> fetched = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'city': data['city'] ?? '',
        'from': data['from'],
        'to': data['to'],
        'image': data['image'] ?? defaultBankImage,
      };
    }).toList();

    setState(() {
      allBanks = fetched;
      isLoading = false;
    });
  }

  String defaultBankImage =
      'https://th.bing.com/th/id/OIP.Kp55bdGUJb_OmNP94QrVYwHaEG?rs=1&pid=ImgDetMain';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredBanks = selectedCity == 'All'
        ? allBanks
        : allBanks.where((place) => place['city'] == selectedCity).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC19DDA),
        title: Text(
          'Available Banks',
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
                delegate: BankSearchDelegate(banks: allBanks),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredBanks.length,
              itemBuilder: (context, index) {
                final bank = filteredBanks[index];
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
                          builder: (_) => BankPlacePage(location: bank),
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
                              Icons.account_balance,
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
                                  bank['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF53336F),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  bank['city'],
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
              }),
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

class BankSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> banks;

  BankSearchDelegate({required this.banks});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: Color(0xFF53336F)),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: Color(0xFF53336F)),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = banks
        .where((bank) =>
            bank['name'].toLowerCase().contains(query.toLowerCase()) ||
            bank['city'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final bank = results[index];
        return ListTile(
          leading: Image.network(
            bank['image'],
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
          title: Text(bank['name']),
          subtitle: Text(bank['city']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BankPlacePage(location: bank),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = banks
        .where((bank) =>
            bank['name'].toLowerCase().contains(query.toLowerCase()) ||
            bank['city'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final bank = suggestions[index];
        return ListTile(
          leading: Image.network(
            bank['image'],
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ),
          title: Text(bank['name']),
          subtitle: Text(bank['city']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BankPlacePage(location: bank),
              ),
            );
          },
        );
      },
    );
  }
}
