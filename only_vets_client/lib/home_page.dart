import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:only_vets_client/bloc/client_notification_bloc.dart';
import 'package:only_vets_client/location_page.dart';
import 'package:only_vets_client/notification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vet Clinic'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _confirmSignOut(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dr. Orosco',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Brgy. Santa Cruz, Naga City',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'M-F  8:00 AM - 5:00 PM',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationPage()),
                );
              },
              child: const Text('Change User Location'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase Authentication
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Remove the token from SharedPreferences
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      // Navigate back to login page and remove all previous routes from stack
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out errors
    }
  }
}
