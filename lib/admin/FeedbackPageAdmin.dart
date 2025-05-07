import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPageAdmin extends StatelessWidget {
  const FeedbackPageAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Users Feedback",
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No feedback available.'));
          }

          final feedbackList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              final data = feedbackList[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${data['email'] ?? 'N/A'}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Rating: ${data['rating'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      if (data['selectedIssues'] != null &&
                          data['selectedIssues'] is List)
                        Text(
                            'Issues: ${(data['selectedIssues'] as List).join(', ')}')
                      else
                        Text('Issues: None'),
                      if ((data['notes'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Notes: ${data['notes']}'),
                      ],
                      if (data['timestamp'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Submitted on: ${DateTime.parse(data['timestamp'].toDate().toString()).toLocal()}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
