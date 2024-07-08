import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'dart:async';
import 'package:flutter/services.dart'; 

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startLoadingProcess();
    // Hide keyboard when this screen is opened
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _startLoadingProcess() {
    // Use a timer to delay the navigation
    _timer = Timer(Duration(seconds: 5), () {
      // Navigate to AuthChecker to handle authentication
      Navigator.pushReplacementNamed(context, '/auth-checker');
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to prevent it from triggering after the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoadingScreen();
  }

  Widget _buildLoadingScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapped outside of a text field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/gradientBG.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1), // Top space
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                  child: Text(
                    'Dr. Orozco',
                    style: GoogleFonts.acme(
                      textStyle: const TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.2), // Space between lines
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                  child: Text(
                    'The Best Care For your Pets',
                    style: GoogleFonts.acme(
                      textStyle: const TextStyle(color: Colors.white, fontSize: 52),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: screenHeight * 0.1), // Space between text and image
                Image.asset('assets/images/dogCat.png'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
