import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // signup creat account
  Future<void> createUserIfNotExists({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String birthDate,
    required bool hasDisability,
  }) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'birthDate': birthDate,
        'hasDisability': hasDisability,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    }
  }

  Future<void> createOwner({
    required String uid,
    required String name,
    required String email,
    required String city,
    required String activity,
  }) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'city': city,
        'activity': activity,
        'role': 'owner',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }


  // Google/Apple Sign In
  Future<void> createUserMinimal({
    required String uid,
    required String email,
    String name = '',
  }) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': '',
        'birthDate': '',
        'hasDisability': false,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    }
  }

  // get user data login
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists) {
      return doc.data();
    } else {
      return null;
    }
  }

  //
  Future<void> updateUserData(String uid, Map<String, dynamic> newData) async {
    await _db.collection('users').doc(uid).update(newData);
  }

  // role
  Future<String?> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['role'];
    }
    return null;
  }

  // يشوف بداتا فعلا موجود اولا
  Future<bool> userExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  //name mnue
  Future<String?> getUserName(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['name'];
      }
    } catch (e) {
      print('Error getting username: $e');
    }
    return null;
  }

  //feedback to admin
  Future<void> addFeedback(Map<String, dynamic> feedbackData) async {
    await _db.collection('feedback').add(feedbackData);
  }

  // feedback to Admin
  Future<List<Map<String, dynamic>>> getAllFeedback() async {
    QuerySnapshot snapshot = await _db
        .collection('feedback')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  //notif
  Future<void> sendNotification(String title, String body) async {
    final notificationsCollection =
        FirebaseFirestore.instance.collection('notifications');

    await notificationsCollection.add({
      'title': title,
      'body': body,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
