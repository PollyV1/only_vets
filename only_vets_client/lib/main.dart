import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/location_bloc.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'location_page.dart';
import 'notification_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Background message data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          navigatorKey.currentState?.pushNamed(response.payload!);
        }
      },
    );

    _showPermissionDialog();
  }

  Future<void> _showPermissionDialog() async {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Grant Notification Permission"),
          content: Text("This app needs notification permission to send you updates."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermissions();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'default_channel',
            'Default Channel',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );

    FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FCM Message received: ${message.notification?.title}");
      _enqueueMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          "FCM Message opened from terminated state: ${message.notification?.title}");
      _enqueueMessage(message);
    });

    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
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
        _processNextMessage();
      });
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      await Future.delayed(Duration(seconds: 2));

      if (_isAppInForeground()) {
        print("App is in foreground, not showing notification");
      } else {
        _showNotification(message.notification?.title, message.notification?.body,
            message.data);
      }

      _handleMessageNavigation(message);

      print("Message handling complete");
    } catch (e) {
      print("Error handling message: $e");
    }
  }

  bool _isAppInForeground() {
    return navigatorKey.currentState?.overlay?.context != null;
  }

  void _showNotification(
      String? title, String? body, Map<String, dynamic> data) async {
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

    await flutterLocalNotificationsPlugin.show(
      0,
      title ?? 'Notification',
      body ?? 'You have a new notification',
      platformChannelSpecifics,
      payload: data['screen'],
    );
  }

  void _handleMessageNavigation(RemoteMessage message) {
    print("Handling navigation from message: ${message.notification?.title}");

    if (message.data.containsKey('screen')) {
      String screenName = message.data['screen']!;
      String? currentRoute = ModalRoute.of(navigatorKey.currentContext!)?.settings.name;
      if (currentRoute != screenName) {
        switch (screenName) {
          case 'home':
            navigatorKey.currentState?.pushReplacementNamed('/home');
            break;
          default:
            navigatorKey.currentState?.pushReplacementNamed('/home');
        }
      }
    } else {
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
      child: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            return MaterialApp(
              title: 'Client App',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              debugShowCheckedModeBanner: false,
              initialRoute:
                  snapshot.hasData && snapshot.data == true ? '/home' : '/login',
              navigatorKey: navigatorKey,
              routes: {
                '/login': (context) => LoginPage(),
                '/register': (context) => RegisterPage(),
                '/location': (context) => LocationPage(),
                '/home': (context) => HomePage(),
                '/notification': (context) => NotificationPage(message: null),
              },
              onGenerateRoute: (settings) {
                if (settings.name == '/notification') {
                  return MaterialPageRoute(
                    builder: (context) => NotificationPage(message: null),
                  );
                }
                return null;
              },
            );
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getString('token') != null;
    return isLoggedIn;
  }
}
