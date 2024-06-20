import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Host Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Location'),
              onChanged: (value) {
                if (value != null) {
                  context.read<NotificationBloc>().add(SendNotification(value));
                }
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
          ],
        ),
      ),
    );
  }
}
