import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:only_vets_client/bloc/client_notification_bloc.dart';
import 'package:only_vets_client/notification_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vet Clinic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. Orosco',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Brgy. Santa Cruz, Naga City',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'M-F  8:00 AM - 5:00 PM',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Trigger sending notification to the host (e.g., Dr. Orosco)
                _sendNotificationToHost(context);
              },
              child: Text('Send Notification to Host'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage(message: null,)),
                );
              },
              child: Text('View Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendNotificationToHost(BuildContext context) {
    // Example of sending a notification to the host
    context.read<ClientNotificationBloc>().add(ClientSendNotification('Naga')); // Replace 'Naga' with the actual location or parameter you want to send
  }
}
