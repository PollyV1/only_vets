import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:only_vets_client/home_page.dart';
import 'package:only_vets_client/notification_page.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/location_bloc.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'location_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final Queue<RemoteMessage> _messageQueue = Queue();
  bool _isProcessingMessage = false;

  MyApp() {
    initializeNotifications();
    configureFirebaseMessaging();
  }

  void initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void configureFirebaseMessaging() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FCM Message received: ${message.notification?.title}");
      _enqueueMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("FCM Message opened from terminated state: ${message.notification?.title}");
      _enqueueMessage(message);
    });

    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
      // Send this token to your server or use it to send notifications to this specific device
    });
  }

  void _enqueueMessage(RemoteMessage message) {
    _messageQueue.add(message);
    _processNextMessage();
  }

  void _processNextMessage() {
    if (!_isProcessingMessage && _messageQueue.isNotEmpty) {
      _isProcessingMessage = true;
      var message = _messageQueue.removeFirst();
      _handleMessage(message).then((_) {
        _isProcessingMessage = false;
        _processNextMessage(); // Process next message in the queue
      });
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      // Simulate background processing
      await Future.delayed(Duration(seconds: 2));

      // Show notification
      _showNotification(message.notification?.title, message.notification?.body);

      // Handle navigation
      _handleMessageNavigation(message);

      print("Message handling complete");
    } catch (e) {
      print("Error handling message: $e");
      // Handle any errors or exceptions here
    }
  }

  void _showNotification(String? title, String? body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Show the new notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title ?? 'Notification',
      body ?? 'You have a new notification',
      platformChannelSpecifics,
      payload: 'item x', // Optional, any value you want to pass to the notification
    );
  }

  void _handleMessageNavigation(RemoteMessage message) {
    // Handle navigation to specific page or actions based on message payload
    print("Handling navigation from message: ${message.notification?.title}");

    // Example: Navigate based on notification data
    if (message.data.containsKey('screen')) {
      String screenName = message.data['screen']!;
      switch (screenName) {
        case 'home':
          navigatorKey.currentState?.pushReplacementNamed('/home');
          break;
        case 'notification':
          navigatorKey.currentState?.pushReplacementNamed('/notification');
          break;
        case 'other_screen':
          // Navigate to another screen based on the payload
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          break;
        default:
          // Navigate to a default screen or handle as needed
          navigatorKey.currentState?.pushReplacementNamed('/home');
      }
    } else {
      // Handle default navigation
      navigatorKey.currentState?.pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        Provider<LocationBloc>(
          create: (context) => LocationBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Client App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        navigatorKey: navigatorKey, // Set the navigatorKey here
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/location': (context) => LocationPage(),
          '/home': (context) => HomePage(),
          '/notification': (context) => NotificationPage(message: null,),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/notification') {
            // Handle specific notification route
            return MaterialPageRoute(
              builder: (context) => NotificationPage(message: null,),
            );
          }
          return null;
        },
      ),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  try {
    // Simulate background processing
    await Future.delayed(Duration(seconds: 2));

    print("Background message handling complete");
  } catch (e) {
    print("Error handling background message: $e");
    // Handle any errors or exceptions here
  }
}
