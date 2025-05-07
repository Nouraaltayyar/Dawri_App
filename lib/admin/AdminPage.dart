import 'package:dawri_app/admin/adminAccount.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AdminQueuesPage.dart';
import 'UserPage.dart';
import 'FeedbackPageAdmin.dart';
import 'adminAccount.dart';
import 'user_manager.dart';
import 'category_views.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final UserManager _userManager = UserManager();
  String selectedCity = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          bottom: TabBar(
            labelColor: Color(0xFF53336F),
            unselectedLabelColor: Colors.black12,
            indicatorColor: Color(0xFF53336F),
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: "Users"),
              Tab(text: "Owners"),
              Tab(text: "Queues"),
            ],
          ),
          backgroundColor: const Color(0xFFC19DDA),
          title: const Text(
            "Admin Home",
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF53336F),
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        endDrawer: Drawer(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 25),
                color: const Color(0xFFC19DDA),
                child: const Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Welcome, Admin!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF53336F),
                      ),
                    ),
                    Text(
                      "Menu",
                      style: TextStyle(fontSize: 16, color: Color(0xFF53336F)),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined,
                    color: Color(0XFF664187)),
                title: const Text("Account"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminOwnerAccountPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.feedback_outlined,
                    color: Color(0XFF664187)),
                title: const Text("User Feedback"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedbackPageAdmin()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                title: const Text("Logout"),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList(roleFilter: 'user'),
            _buildUserList(roleFilter: 'owner'),
            _buildQueuesTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList({required String roleFilter}) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _userManager.getUsersByRole(roleFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No $roleFilter accounts found.'));
        } else {
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserPage(
                        user: user,
                        role:
                            roleFilter, // <-- اضفنا هذا السطر عشان نمرر نوع الحساب
                        onUserDelete: (deletedUser) async {
                          await _userManager.deleteUser(user['id']!);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${roleFilter.capitalize()} deleted successfully!')),
                          );
                        },
                        onUserUpdate: (updatedUser) async {
                          await _userManager.updateUser(
                              user['id']!, updatedUser);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${roleFilter.capitalize()} updated successfully!')),
                          );
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${user['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF53336F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Phone: ${user['phone']}'),
                        const SizedBox(height: 8),
                        Text('Email: ${user['email']}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildQueuesTabs() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Restaurants"),
              Tab(text: "Cafes"),
              Tab(text: "HealthCare"),
              Tab(text: "Events"),
              Tab(text: "Banks"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                CategoryView(category: "Restaurants"),
                CategoryView(category: "Cafes"),
                CategoryView(category: "HealthCare facilities"),
                CategoryView(category: "Events"),
                CategoryView(category: "Banks"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
