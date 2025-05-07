/*import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String serverKey = 'SERVER_KEY';

  static Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }
}
*/
