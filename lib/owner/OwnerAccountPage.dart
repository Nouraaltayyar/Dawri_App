import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class OwnerAccountPage extends StatefulWidget {
  const OwnerAccountPage({super.key});

  @override
  _OwnerAccountPageState createState() => _OwnerAccountPageState();
}

class _OwnerAccountPageState extends State<OwnerAccountPage> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _activityController;
  late TextEditingController _emailController;
  String role = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _activityController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final data = await DatabaseService().getUserData(uid);
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _cityController.text = data['city'] ?? '';
          _activityController.text = data['activity'] ?? '';
          _emailController.text = data['email'] ?? '';
          role = data['role'] ?? '';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _activityController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "",
          style: TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF53336F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF664187),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFFc19dda),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildInfoTile('Name', _nameController),
                    buildInfoTile('City', _cityController),
                    buildInfoTile('Activity', _activityController),
                    buildInfoTile('Email', _emailController),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf3e3f9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user,
                              color: Color(0xFF53336F)),
                          const SizedBox(width: 10),
                          Text(
                            "Role: ${role.toUpperCase()}",
                            style: const TextStyle(
                                fontSize: 18, color: Color(0xFF53336F)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final uid =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                          if (uid.isNotEmpty) {
                            await DatabaseService().updateUserData(uid, {
                              'name': _nameController.text,
                              'city': _cityController.text,
                              'activity': _activityController.text,
                              'email': _emailController.text,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Changes saved successfully")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF664187),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Save Changes",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildInfoTile(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFf3e3f9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF53336F),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
