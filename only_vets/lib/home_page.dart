import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'bloc/notification_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  List<String> sentLocations = [];

  @override
  void initState() {
    super.initState();
    // For demonstration, adding dummy data
    sentLocations = [];
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double screenHeight = MediaQuery.of(context).size.height;
    double verticalSpace = screenHeight * 0.1; // Adjust this factor as needed

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/gradientBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: verticalSpace),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Click the Ring Icon Below to Start Pinging',
                            style: GoogleFonts.acme(
                              textStyle: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 27),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(80), // Adjust the radius as needed
                        child: Image.asset(
                          'assets/images/phoneWhite.png',
                          fit: BoxFit.cover,
                          width: 120, // Set the desired width
                          height: 120, // Set the desired height for a square image
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 27),
                  Container(
                    width: 220, // Adjust the width as needed
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color for the dropdown hint
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        icon: const SizedBox.shrink(),
                        value: selectedLocation,
                        decoration: const InputDecoration(
                          border: InputBorder.none, // Hide the border
                          contentPadding: EdgeInsets.only(bottom: 10, top: 10),
                          hintText: 'Select Location',
                          hintStyle: TextStyle(color: Colors.black),
                          alignLabelWithHint: true,
                        ),
                        dropdownColor: Colors.white, // Dropdown background color
                        style: const TextStyle(color: Colors.black, fontSize: 20), 
                        onChanged: (value) async {
                          setState(() {
                            selectedLocation = value;
                          });

                          if (selectedLocation != null) {
                            bool notificationSent = await _sendNotificationToFirestore(selectedLocation!);
                            if (notificationSent) {
                              Fluttertoast.showToast(
                                msg: 'Notification sent successfully',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Failed to send notification',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          }
                        },
                        items: locations.map((location) {
                          return DropdownMenuItem(
                            value: location,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                location,
                                style: const TextStyle(color: Colors.black, fontSize: 20), 
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  if (sentLocations.isNotEmpty)
                    Container(
                      height: 150, // Adjust the height as needed
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10,),
                           Text(
                            'Previous Pings:',
                            style: GoogleFonts.actor(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          ),
                          const SizedBox(height: 25),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Scrollbar(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:35.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: sentLocations.length,
                                    itemBuilder: (context, index) {
                                      return Text(
                                        sentLocations[index],
                                        style: GoogleFonts.actor(
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _resetSentLocations();
                    },
                    child: const Text('Reset Pings'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, backgroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded edges
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 50,
              right: 50,
              bottom: 10, // Adjust bottom position as needed
              child: ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded edges
                  ),
                ),
                child: Text(
                  'Exit Application',
                  style: GoogleFonts.acme(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: statusBarHeight,
              right: 16.0, // Position the button at the right
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  _confirmSignOut(context);
                },
              ),
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
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Logout"),
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
      await Future.delayed(Duration.zero); // Add this line
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      // Navigate back to login page and remove all previous routes from stack
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out errors
    }
  }

  void _resetSentLocations() {
    setState(() {
      sentLocations.clear();
    });
  }

  Future<bool> _sendNotificationToFirestore(String location) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('location', isEqualTo: location)
          .get();

      if (snapshot.docs.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No users found at $location',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.yellow,
          textColor: Colors.black,
          fontSize: 16.0,
        );
        return false;
      }

      // Dispatch SendNotification event to NotificationBloc
      context.read<NotificationBloc>().add(SendNotification(location));

      // Update sentLocations with the new format
      setState(() {
        sentLocations.add(
          '$location - ${DateFormat.MMMd().add_jm().format(DateTime.now())}',
        );
      });

      return true;
    } catch (e) {
      print('Error sending notification to bloc: $e');
      return false;
    }
  }
}