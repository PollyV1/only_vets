import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Add provider import
import 'bloc/location_bloc.dart';

class LocationPage extends StatelessWidget {
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
    return Provider<LocationBloc>(
      create: (context) => LocationBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
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
                      if (value != null) {
                        context.read<LocationBloc>().add(LocationSelected(value));
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
