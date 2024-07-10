import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:only_vets/auth_bloc/auth_bloc.dart';
import 'package:only_vets/auth_bloc/auth_checker.dart';
import 'package:only_vets/host_login_page.dart';
import 'package:only_vets/register_page.dart';
import 'bloc/notification_bloc.dart';
import 'home_page.dart';
import 'loading_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Ensure status bar icons are visible
    ));
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Host App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: LoadingScreen(), // Set the loading screen as the initial screen
        routes: {
          '/auth-checker': (context) => const AuthChecker(),
          '/login': (context) => HostLoginPage(),
          '/home': (context) => HomePage(),
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}
