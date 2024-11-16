import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/palette.dart';
import '../constants.dart';
import 'package:go_router/go_router.dart';


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

  Future<void> _registerUser(String username, String email, String password, String confirmPassword) async {
    try {
      final String timezone = DateTime.now().timeZoneName;

      final response = await http.post(
        Uri.parse(registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
          'timezone': timezone,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! Please verify your email.')),
          );
          context.go('/signin');
        } else {
          final String message = responseData['message']?.toString() ?? 'Unable to register. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else if (response.statusCode == 422) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        String errorMessages = 'Please fix the following errors:\n';
        errors.forEach((key, value) {
          errorMessages += '- ${key.toUpperCase()}: ${(value as List).join(', ')}\n';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessages)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Try again later.')),
        );
      }
    } on http.ClientException catch (e) {
      // HTTP client-level errors
      print('ClientException: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client error occurred: $e')),
      );
    } on FormatException catch (e) {
      // Errors in parsing the response
      print('FormatException: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid response format from the server: $e')),
      );
    } on Exception catch (e) {
      // Catch unexpected exceptions
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }



  Future<void> _signUpWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

    try {
      // Force account selection
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final String? googleToken = googleAuth.accessToken;

        if (googleToken == null) {
          throw Exception('Failed to retrieve Google access token.');
        }

        // Call your server's Google Sign-Up endpoint with the Google token
        final response = await http.post(
          Uri.parse(googleLoginEndpoint), // Replace with your endpoint
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $googleToken',
          },
        );

        print('Google Sign-Up Response Status: ${response.statusCode}');
        print('Google Sign-Up Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;

          if (responseData['success'] == true) {
            final String message =
                responseData['message']?.toString() ?? 'Google Sign-Up Successful';
            final String token = responseData['token']?.toString() ?? '';
            final int userId = responseData['user']['id'] as int;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );

            // Save session
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            await prefs.setInt('userId', userId);

            // Navigate to the MainMenuScreen
            context.go('/');
          } else {
            final String errorMessage =
                responseData['message']?.toString() ?? 'Google Sign-Up Failed.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          }
        } else {
          final String errorMessage =
              'Google Sign-Up Failed with status code ${response.statusCode}.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } else {
        // User canceled the Google sign-in process
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In canceled.')),
        );
      }
    } catch (error) {
      print('Google Sign-Up Error: $error');
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

                  _registerUser(username, email, password, confirmPassword);
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                onPressed: _signUpWithGoogle,
                label: const Text('Sign Up with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
