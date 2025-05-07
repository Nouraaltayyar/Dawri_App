import 'package:cloud_firestore/cloud_firestore.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory UserManager() => _instance;

  UserManager._internal();

  Future<List<Map<String, String>>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name']?.toString() ?? '',
          'phone': data['phone']?.toString() ?? '',
          'dob': data['birthDate']?.toString() ?? '',
          'email': data['email']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<void> addUser(Map<String, String> newUser) async {
    await _firestore.collection('users').add({
      'name': newUser['name'],
      'phone': newUser['phone'],
      'birthDate': newUser['dob'],
      'email': newUser['email'],
      'role': 'user',
    });
  }

  Future<void> updateUser(String userId, Map<String, String> updatedUser) async {
    await _firestore.collection('users').doc(userId).update({
      'name': updatedUser['name'],
      'phone': updatedUser['phone'],
      'birthDate': updatedUser['dob'],
      'email': updatedUser['email'],
    });
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }


  Future<List<Map<String, String>>> getUsersByRole(String role) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name']?.toString() ?? '',
          'phone': data['phone']?.toString() ?? '',
          'dob': data['birthDate']?.toString() ?? '',
          'email': data['email']?.toString() ?? '',
          'hasDisability': data['hasDisability']?.toString() ?? 'false',
        };
      }).toList();
    } catch (e) {
      print('Error fetching $role accounts: $e');
      return [];
    }
  }

}
