import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeline_tile/timeline_tile.dart';

class AdminQueuesPage extends StatefulWidget {
  final Map<String, dynamic> place;

  const AdminQueuesPage({super.key, required this.place});

  @override
  _AdminQueuesPageState createState() => _AdminQueuesPageState();
}

class _AdminQueuesPageState extends State<AdminQueuesPage> {
  late Stream<QuerySnapshot> queueStream;

  @override
  void initState() {
    super.initState();
    final placeId = widget.place['id'];
    queueStream = FirebaseFirestore.instance
        .collection('reservations')
        .where('locationId', isEqualTo: placeId)
        .where('canceled', isEqualTo: false)
        .orderBy('time')
        .snapshots();
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return {
        'name': data['name'] ?? 'Unknown',
        'hasDisability': data['hasDisability'] ?? false,
      };
    } else {
      return {
        'name': 'Unknown',
        'hasDisability': false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF53336F),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: queueStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final queueList = snapshot.data?.docs ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  bottom: 70), // To avoid overlap with button
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      ' ${place['name']}',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "A total of ${queueList.length} people are in this queue.",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      color: Color(0xFF7b5b98),
                      thickness: 2,
                      indent: 10,
                      endIndent: 10,
                    ),
                    ...queueList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value.data() as Map<String, dynamic>;
                      final userId = data['userId'] ?? 'Unknown';
                      final time = data['time'] ?? 'N/A';

                      return FutureBuilder<Map<String, dynamic>>(
                        future: getUserInfo(userId),
                        builder: (context, snapshot) {
                          final userInfo = snapshot.data ??
                              {
                                'name': 'Loading...',
                                'hasDisability': false,
                              };

                          String displayName = userInfo['name'];
                          if (userInfo['hasDisability'] == true) {
                            displayName += ' 🌟';
                          }

                          return CustomTimelineTile(
                            title: displayName,
                            time: time,
                            isFirst: index == 0,
                            isLast: index == queueList.length - 1,
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomTimelineTile extends StatelessWidget {
  final String title;
  final String time;
  final bool isFirst;
  final bool isLast;

  const CustomTimelineTile({
    super.key,
    required this.title,
    required this.time,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasStar = title.contains('🌟');
    final cleanTitle = title.replaceAll('🌟', '');

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // الوقت (يمين)
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 16),

        // الخط والدائرة
        SizedBox(
          height: 60,
          width: 30,
          child: TimelineTile(
            axis: TimelineAxis.vertical,
            alignment: TimelineAlign.manual,
            lineXY: 0.5,
            isFirst: isFirst,
            isLast: isLast,
            beforeLineStyle: const LineStyle(
              thickness: 5,
              color: Color(0xFFC19DDA),
            ),
            afterLineStyle: const LineStyle(
              thickness: 5,
              color: Color(0xFFC19DDA),
            ),
            indicatorStyle: const IndicatorStyle(
              width: 30,
              color: Color(0xFF53336F),
            ),
            startChild: const SizedBox.shrink(),
            endChild: const SizedBox.shrink(),
          ),
        ),

        const SizedBox(width: 16),

        // الاسم ثم النجمة
        Row(
          children: [
            Text(
              cleanTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasStar)
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Text(
                  '🌟',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
