import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  final Map<String, String> user;
  final String role; // <-- اضفنا role هنا
  final Function(Map<String, String>) onUserDelete;
  final Function(Map<String, String>) onUserUpdate;

  const UserPage({
    super.key,
    required this.user,
    required this.role, // <-- required
    required this.onUserDelete,
    required this.onUserUpdate,
  });

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isOwner = widget.role == 'owner'; // <-- تحقق اذا هو owner

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          isOwner
              ? "Owner Details"
              : "User Details", // <-- نص العنوان حسب النوع
          style: const TextStyle(
            color: Color(0xFF53336F),
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
      body: SingleChildScrollView(
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
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF664187),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFFc19dda),
                    ),
                  ),
                  if (widget.user['hasDisability'] == 'true')
                    const Positioned(
                      top: -2,
                      right: -2,
                      child: Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              buildInfoTile('Name', user['name']!),
              buildInfoTile('Date of birth', user['dob']!),
              buildInfoTile('Phone Number', user['phone']!),
              buildInfoTile('Email', user['email']!),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showEditUserDialog(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53336F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    isOwner
                        ? "Edit Owner"
                        : "Edit User", // <-- النص يتغير حسب النوع
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDeleteConfirmationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53336F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    isOwner
                        ? "Delete Owner"
                        : "Delete User", // <-- النص يتغير حسب النوع
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoTile(String label, String value) {
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
            '$label: ',
            style: const TextStyle(fontSize: 16, color: Color(0xFF53336F)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void showEditUserDialog(Map<String, String> user) {
    TextEditingController nameController =
        TextEditingController(text: user['name']);
    TextEditingController dobController =
        TextEditingController(text: user['dob']);
    TextEditingController phoneController =
        TextEditingController(text: user['phone']);
    TextEditingController emailController =
        TextEditingController(text: user['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTextField('Name', nameController),
              buildTextField('Date of Birth', dobController),
              buildTextField('Phone Number', phoneController),
              buildTextField('Email', emailController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    dobController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  final updatedUser = {
                    'name': nameController.text,
                    'dob': dobController.text,
                    'phone': phoneController.text,
                    'email': emailController.text,
                  };
                  widget.onUserUpdate(updatedUser);
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF53336F)),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF53336F), width: 2),
          ),
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete"),
          content: const Text("Are you sure you want to delete this account?"),
          actions: [
            TextButton(
              onPressed: () {
                widget.onUserDelete(widget.user);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }
}
