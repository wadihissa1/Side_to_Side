import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../style/palette.dart';
import '../constants.dart'; // Import constants

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;

  Future<void> _registerUser(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final String message = responseData['message']?.toString() ?? 'Registration successful';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          final String message = responseData['message']?.toString() ?? 'Registration failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register. Please try again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundSignUp.color,
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(color: palette.signUpText.color),
        ),
        backgroundColor: palette.backgroundSignUp.color,
        iconTheme: IconThemeData(color: palette.signUpText.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username Field
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: palette.signUpText.color),
                border: const OutlineInputBorder(),
              ),
              style: TextStyle(color: palette.signUpText.color),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: palette.signUpText.color),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: palette.signUpText.color),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: palette.signUpText.color),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              style: TextStyle(color: palette.signUpText.color),
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: palette.signUpText.color),
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
              style: TextStyle(color: palette.signUpText.color),
            ),
            const SizedBox(height: 16),

            // Terms & Conditions Checkbox
            Row(
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value!;
                    });
                  },
                  activeColor: palette.signUpButton.color,
                ),
                Expanded(
                  child: Text(
                    'I accept the Terms & Conditions and Privacy Policy.',
                    style: TextStyle(color: palette.signUpText.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.signUpButton.color,
                foregroundColor: palette.signUpButtonText.color,
              ),
              onPressed: () {
                if (!_acceptedTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please accept the Terms & Conditions.')),
                  );
                  return;
                }

                final username = usernameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match.')),
                  );
                  return;
                }

                _registerUser(username, email, password);
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),

            // Sign Up with Google Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.g_mobiledata, color: Colors.red),
              onPressed: () async {
                // Call Google Login Endpoint
                try {
                  final response = await http.post(
                    Uri.parse(googleLoginEndpoint),
                    headers: {'Content-Type': 'application/json'},
                  );
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Google Sign-Up Successful!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Google Sign-Up Failed!')),
                    );
                  }
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                }
              },
              label: const Text('Sign Up with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
