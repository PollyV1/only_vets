import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:only_vets_client/home_page.dart';
import 'package:provider/provider.dart';
import 'bloc/location_bloc.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final List<String> locations = [
    'Bombon',
    'Calabanga',
    'Canaman',
    'Magarao',
    'Tinambac',
    'Siruma',
    'Naga'
  ];

  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Provider<LocationBloc>(
      create: (context) => LocationBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Select Location'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton<String>(
                hint: Text('Select Location'),
                onChanged: (value) {
                  _showLocationChangeConfirmationDialog(value!);
                },
                items: locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              if (selectedLocation != null) // Show message if location is selected
                Text(
                  'Location changed to: $selectedLocation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              BlocBuilder<LocationBloc, LocationState>(
                builder: (context, state) {
                  if (state is LocationUploaded) {
                    return Text('Location uploaded successfully.');
                  } else if (state is LocationError) {
                    return Text('Error: ${state.message}');
                  }
                  return Container();
                },
              ),
              Spacer(), // Spacer to push the button to the bottom
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationChangeConfirmationDialog(String location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Location Change'),
          content: Text('Are you sure you want to change location to $location?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  selectedLocation = location;
                });
                context.read<LocationBloc>().add(LocationSelected(location));
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
}
