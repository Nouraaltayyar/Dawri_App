import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailsReview extends StatelessWidget {
  final String locationId;

  const DetailsReview({Key? key, required this.locationId}) : super(key: key);

  Future<String> _getLocationDetails(String locationId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('locations')
          .doc(locationId)
          .get();

      if (doc.exists) {
        return doc.get('details') ?? 'No details available';
      }
      return 'No details available';
    } catch (e) {
      print('[ERROR] Failed to fetch location details: $e');
      return 'Failed to load details';
    }
  }

  Future<List<Map<String, dynamic>>> _getFeedbackWithUsernames(
      String locationId) async {
    print('[DEBUG] Fetching feedback for locationId: $locationId');

    final feedbackQuery = await FirebaseFirestore.instance
        .collection('reviews')
        .where('locationId', isEqualTo: locationId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> feedbackList = [];

    for (var doc in feedbackQuery.docs) {
      final data = doc.data();
      final userId = data['userId'];
      String username = 'Unknown';

      if (userId != null) {
        print('[DEBUG] Fetching user with ID: $userId');

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          username = userDoc.data()?['name'] ?? 'Unknown';
          print('[DEBUG] Found username: $username');
        } else {
          print('[DEBUG] User document not found for ID: $userId');
        }
      }

      feedbackList.add({
        'username': username,
        'rating': data['rating']?.toDouble() ?? 0.0,
        'notes': data['notes'] ?? '',
        'timestamp': data['timestamp'],
      });
    }

    print('[DEBUG] Total feedback found: ${feedbackList.length}');
    return feedbackList;
  }

  Future<double> _calculateAverageRating(String locationId) async {
    final query = await FirebaseFirestore.instance
        .collection('reviews')
        .where('locationId', isEqualTo: locationId)
        .get();

    if (query.docs.isEmpty) return 0.0;

    double total = 0.0;
    for (var doc in query.docs) {
      total += (doc['rating']?.toDouble() ?? 0.0);
    }

    final average = total / query.docs.length;
    print('[DEBUG] Calculated average rating: $average');
    return average;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF664187),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF664187),
            tabs: [
              Tab(text: "Details"),
              Tab(text: "Review"),
            ],
          ),
          Container(
            height: 250,
            padding: const EdgeInsets.all(10),
            child: TabBarView(
              children: [
                FutureBuilder<String>(
                  future: _getLocationDetails(locationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Text(
                      snapshot.data ?? 'No details available',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14),
                    );
                  },
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getFeedbackWithUsernames(locationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No reviews yet."));
                    }

                    final feedbackList = snapshot.data!;
                    return FutureBuilder<double>(
                      future: _calculateAverageRating(locationId),
                      builder: (context, avgSnapshot) {
                        final avgRating = avgSnapshot.data ?? 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "⭐ Average Rating: ${avgRating.toStringAsFixed(1)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                itemCount: feedbackList.length,
                                itemBuilder: (context, index) {
                                  final item = feedbackList[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: ListTile(
                                      leading: const Icon(Icons.account_circle,
                                          size: 35),
                                      title: Text(
                                        item['username'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: List.generate(
                                              5,
                                              (i) => Icon(
                                                i < item['rating']
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(item['notes']),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
