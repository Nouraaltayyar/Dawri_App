import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class QueuesPage extends StatefulWidget {
  final Map<String, String> place;

  const QueuesPage({super.key, required this.place});

  @override
  _QueuesPageState createState() => _QueuesPageState();
}

class _QueuesPageState extends State<QueuesPage> {
  @override
  Widget build(BuildContext context) {
    final place = widget.place;

    return Scaffold(
      //backgroundColor: const Color(0xFFF7EFE5),
      appBar: AppBar(
        title: const Text(
          "Queue Details",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF53336F),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Container for the timeline
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Card(
                    color: const Color(0xFFC19DDA),
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${place['name']}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "A total of ${place['queueCount']} people are in this queue.",
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Timeline for people in queue
                  CustomTimelineTile(
                    title: 'Dana',
                    isFirst: true,
                    time: '10:00am',
                  ),
                  CustomTimelineTile(title: 'Nora', time: '10:10am'),
                  CustomTimelineTile(
                    title: 'Fatima',
                    isLast: true,
                    time: '10:20am',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 350),
            // Added the Confirm button again
            /*ElevatedButton(
              onPressed: () {
                // Handle the confirmation action here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC19DDA),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}

// CustomTimelineTile example
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
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: const LineStyle(
        thickness: 8,
        color: Color(0xFFb58cda),
      ),
      indicatorStyle: const IndicatorStyle(
        color: Color(0xFF7b5b98),
        width: 25,
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
