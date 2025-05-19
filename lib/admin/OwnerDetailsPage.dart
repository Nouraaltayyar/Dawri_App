import 'package:flutter/material.dart';

class OwnerDetailsPage extends StatelessWidget {
  final String ownerName;
  final String ownerEmail;
  final String ownerCity;
  final String ownerActivity;
  final String ownerRole;

  const OwnerDetailsPage({
    Key? key,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerCity,
    required this.ownerActivity,
    required this.ownerRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Details'),
        centerTitle: true,
        backgroundColor: Colors.purple[100],
        foregroundColor: Colors.purple[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow('Name', ownerName),
                    _buildRow('Email', ownerEmail),
                    _buildRow('City', ownerCity),
                    _buildRow('Activity', ownerActivity),
                    _buildRow('Role', ownerRole),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildButton(context, 'Details Owner', Colors.purple.shade700),
            const SizedBox(height: 16),
            _buildButton(context, 'Edit Owner', Colors.blue.shade700),
            const SizedBox(height: 16),
            _buildButton(context, 'Delete Owner', Colors.red.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$text button pressed')),
          );
        },
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
