import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bloc/notification_bloc.dart';

class HomePage extends StatelessWidget {
  final List<String> locations = [
    'Bombon',
    'Calabanga',
    'Canaman',
    'Magarao',
    'Tinambac',
    'Siruma',
    'Naga'
  ];

  @override
  Widget build(BuildContext context) {
    String? selectedLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text('Host Home'),
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
          children: [
            DropdownButton<String>(
              hint: Text('Select Location'),
              onChanged: (value) {
                selectedLocation = value;
              },
              items: locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationSent) {
                  return Text('Notification sent successfully.');
                } else if (state is NotificationError) {
                  return Text('Error: ${state.message}');
                }
                return Container();
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedLocation != null) {
                  context.read<NotificationBloc>().add(SendNotification(selectedLocation!));
                }
              },
              child: Text('Send Notification'),
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
                await _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase Authentication
      // You can also clear any local storage or session data here if necessary
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      // Navigate back to login page and remove all previous routes from stack
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out errors
    }
  }
}
