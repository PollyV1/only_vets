import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String notificationMessage = 'No notifications yet';

  @override
  void initState() {
    super.initState();
    _configureFirebaseMessaging();
    _askForNotificationPermission();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification'); // Replace with your icon name

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _askForNotificationPermission() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Client received message: ${message.notification?.title}");
      setState(() {
        notificationMessage =
            '${message.notification?.title}\n${message.notification?.body}';
      });
      _showNotification(message.notification?.title, message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Client opened from message: ${message.notification?.title}");
      // Handle notification when app is in background but opened by tapping on notification
    });

    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
      // Send this token to your server or use it to send notifications to this specific device
    });
  }

  Future<void> _showNotification(String? title, String? body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', // Replace with your own channel id
      'your channel description', // Replace with your own channel description
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      // other properties...
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title ?? 'Notification', // Notification title
      body ?? 'You have a new notification', // Notification body
      platformChannelSpecifics,
      payload: 'item x', // Optional payload
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            notificationMessage,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
