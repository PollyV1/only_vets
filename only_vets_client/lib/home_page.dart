import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:only_vets_client/location_page.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the external_app_launcher package

class BottomRoundedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20); // start from bottom left corner
    path.quadraticBezierTo(0, size.height, 20, size.height); // bottom left curve
    path.lineTo(size.width - 20, size.height); // bottom right curve
    path.quadraticBezierTo(size.width, size.height, size.width, size.height - 20); // end at bottom right corner
    path.lineTo(size.width, 0); // line to top right
    path.lineTo(0, 0); // line to top left
    path.close(); // close the path to form a closed shape
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set status bar color to white
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, // Ensure status bar icons are visible
    ));

    double statusBarHeight = MediaQuery.of(context).padding.top;

    // Get height of the doc.png image
    double docImageHeight = MediaQuery.of(context).size.width * 0.6; // Adjust as needed

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(61, 52, 52, 1),
              ),
              child: Text(
                'Other Functions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Change User Location'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Disclaimer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _confirmSignOut(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/gradientBG.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomRoundedClipper(),
              child: Image.asset(
                'assets/images/doc.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight,
            left: 16,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight + docImageHeight, left: 15, right: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Orosco',
                    style: GoogleFonts.acme(
                      textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'M-F  8:00 AM - 5:00 PM',
                        style: GoogleFonts.acme(
                          textStyle: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'About the Clinic',
                    style: GoogleFonts.acme(
                      textStyle: const TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Based in Brgy. Santa Cruz, Naga City. Dr. Orosco has been in service for the past 10 years caring for different breeds of cats and dogs under different mild to severe conditions.',
                      style: GoogleFonts.acme(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  _buildGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    List<String> gridItems = [
      'Clinic Location',
      'Messenger',
      'Email',
      'Phone Number',
    ];

    List<String> imageFiles = [
      'assets/images/clinic.png',
      'assets/images/message.png',
      'assets/images/email.png',
      'assets/images/phone.png',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        childAspectRatio: 1.3,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            _onGridItemClick(context, index);
          },
          child: Card(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imageFiles[index],
                  height: 50,
                  width: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  gridItems[index],
                  style: GoogleFonts.acme(
                    textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onGridItemClick(BuildContext context, int index) async {
    switch (index) {
      case 0:
        // Handle Clinic Location click
        double latitude = 13.627138519317034;
        double longitude = 123.18654235273448;
        String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissing by clicking outside
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Redirecting to Google Maps'),
              content: const Text('You will now be redirected to Google Maps to view the clinic location.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'), // Add a Cancel button
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(); // Close the dialog

                    try {
                      // Attempt to launch Google Maps URL
                      await launch(googleMapsUrl);
                    } catch (e) {
                      // Error handling if launch fails
                      print('Error launching Google Maps URL: $e');
                      try {
                        // Try opening Google Maps app directly
                        await LaunchApp.openApp(
                          androidPackageName: 'com.google.android.apps.maps',
                          iosUrlScheme: 'comgooglemaps://',
                          appStoreLink: 'https://apps.apple.com/us/app/google-maps-transit-food/id585027354',
                        );
                      } catch (launchAppError) {
                        // Error handling if opening Google Maps app fails
                        print('Error opening Google Maps app: $launchAppError');
                        showDialog(
                          context: context,
                          builder: (BuildContext errorDialogContext) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Failed to open Google Maps. Please try again later.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(errorDialogContext).pop(); // Close the dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
        break;
      case 1:
        // Handle Messenger click
        // For example, open a Messenger URL or navigate to a Messenger page
        break;
      case 2:
        // Handle Email click
        // For example, open an email client with a predefined email address
        break;
      case 3:
        // Handle Phone Number click
        try {
          const phoneNumber = "1234567"; // Replace with your desired phone number
          String url = 'tel:$phoneNumber';
          
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        } catch (e) {
          print('Error launching phone call: $e');
          
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Could not make the call'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Failed to initiate phone call. Please try again later. Or you can copy the number below'),
                    const SizedBox(height: 10),
                    Text('Phone Number: 1234567'), // Replace with your actual phone number
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('Copy'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '1234567')); // Replace with your actual phone number
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Phone number copied to clipboard')),
                            );
                            Navigator.of(dialogContext).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Close the dialog
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
        break;

    }
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
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      // Navigate back to login page and remove all previous routes from stack
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out errors
    }
  }

  void _launchPhoneCall(BuildContext context, String phoneNumber) async {
    if (await Permission.phone.request().isGranted) {
      String url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      // Permission denied, show an explanation and request permission again
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('This app needs access to make phone calls.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                  openAppSettings(); // Open app settings to allow the user to grant permission
                },
              ),
            ],
          );
        },
      );
    }
  }

}
