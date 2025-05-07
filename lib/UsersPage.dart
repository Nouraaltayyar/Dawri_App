import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool isLoading = true;
  bool hasDisability = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _phoneController = TextEditingController();
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
          _dobController.text = data['birthDate'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? '';
          hasDisability = data['hasDisability'] ?? false;
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC19DDA),
        title: const Text(
          "User account",
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
                    Stack(
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
                        if (hasDisability)
                          const Positioned(
                            top: -6,
                            left: -5,
                            child: Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 36,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildEditableInfoTile('Name', _nameController),
                    buildEditableInfoTile('Date of birth', _dobController),
                    buildEditableInfoTile('Phone Number', _phoneController),
                    buildEditableInfoTile('Email', _emailController),
                    const SizedBox(height: 20),
                    // Disability Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf3e3f9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Are you a person with disability?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: hasDisability,
                            onChanged: (value) {
                              setState(() {
                                hasDisability = value;
                              });
                            },
                            activeColor: Colors.deepPurple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasDisability
                              ? Icons.accessible
                              : Icons.not_accessible,
                          color:
                              hasDisability ? Colors.deepPurple : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasDisability
                              ? "User has a disability"
                              : "No disability",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                              'birthDate': _dobController.text,
                              'phone': _phoneController.text,
                              'email': _emailController.text,
                              'hasDisability': hasDisability,
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Changes saved successfully")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF53336F),
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

  Widget buildEditableInfoTile(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFf3e3f9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(color: Color(0xFF53336F)),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
