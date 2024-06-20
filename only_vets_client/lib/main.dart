import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Add provider import
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
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
          '/location': (context) => LocationPage(),
        },
      ),
    );
  }
}
