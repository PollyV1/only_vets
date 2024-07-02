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
      _showNotification(message.notification?.title, message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("FCM Message opened from terminated state: ${message.notification?.title}");
      // Handle navigation to notification page
      if (message != null) {
        _handleMessageNavigation(message);
      }
    });

    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
      // Send this token to your server or use it to send notifications to this specific device
    });
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

    // Cancel any existing notifications before showing a new one
    await flutterLocalNotificationsPlugin.cancelAll();

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
    // Example: Navigate to a specific screen based on notification content
    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (context) => NotificationPage(message: message)),
    );
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
}
