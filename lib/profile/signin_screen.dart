import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../style/palette.dart';
import '../constants.dart'; // Import constants
import 'profile_screen.dart'; // Import profile screen

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Future<void> _signIn(BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint), // Use constant for login endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final String message = responseData['message']?.toString() ?? 'Login successful';
          final String token = responseData['token']?.toString() ?? '';
          final int userId = responseData['user']['id'] as int; // Fetch user ID from the response

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          // Navigate to ProfileScreen and pass token and userId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: userId, token: token),
            ),
          );
        } else {
          final String message = responseData['message']?.toString() ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else if (response.statusCode == 403) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final String message = responseData['message']?.toString() ?? 'Email not verified.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The provided credentials do not match our records.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login. Please try again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final String? token = googleAuth.accessToken;

        // Call the API with the Google token
        final response = await http.post(
          Uri.parse(googleLoginEndpoint), // Use constant for Google login endpoint
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
          if (responseData['success'] == true) {
            final String message = responseData['message']?.toString() ?? 'Google Sign-In successful!';
            final int userId = responseData['user']['id'] as int; // Fetch user ID from response

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );

            // Navigate to ProfileScreen and pass token and userId
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: userId, token: token!),
              ),
            );
          } else {
            final String message = responseData['message']?.toString() ?? 'Google Sign-In failed.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google Sign-In failed with status code ${response.statusCode}.')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: palette.backgroundSignIn.color,
      appBar: AppBar(
        title: Text(
          'Sign In',
          style: TextStyle(color: palette.signInText.color),
        ),
        backgroundColor: palette.backgroundSignIn.color,
        iconTheme: IconThemeData(color: palette.signInText.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: palette.signInText.color),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: palette.signInText.color),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: palette.signInText.color),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              style: TextStyle(color: palette.signInText.color),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.signInButton.color,
                foregroundColor: palette.signInButtonText.color,
              ),
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;
                _signIn(context, email, password);
              },
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.signInButton.color,
                foregroundColor: palette.signInButtonText.color,
              ),
              onPressed: () {
                _signInWithGoogle(context); // Call Google Sign-In function
              },
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
