import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:only_vets_client/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _askNotificationPermission();
  }

  void _askNotificationPermission() async {
    if (!await Permission.notification.isGranted) {
      PermissionStatus status = await Permission.notification.request();
      if (status != PermissionStatus.granted) {
        // Permission not granted, show alert dialog
        _showNotificationPermissionDeniedDialog();
      }
    }
  }

  void _showNotificationPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Permission Required'),
          content: Text('Please grant notification permission to continue.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _askNotificationPermission(); // Request notification permission again
              },
            ),
          ],
        );
      },
    );
  }

  void _loginUser(BuildContext context) async {
    String errorMessage = 'An unknown error occurred.'; // Default error message

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save token to shared preferences upon successful login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userCredential.user!.uid);

      // Navigate to home page
      Navigator.pushReplacementNamed(context, '/home');
      return; // Exit method if login is successful
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException errors
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'The user corresponding to this email has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'network-request-failed':
          errorMessage = 'No internet connection.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid Password provided.';
          break;
        case 'channel-error':
          errorMessage = 'Please enter a valid Email or correct password';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
          break;
      }
    } catch (e) {
      // Handle other exceptions (if any)
      errorMessage = 'An unknown error occurred.';
    }

    // Print the error message for debugging
    print("Error logging in: $errorMessage");

    // Display toast with the error message
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Only Vets Client')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loginUser(context),
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Don\'t have an account? Register here.'),
            ),
          ],
        ),
      ),
    );
  }
}
