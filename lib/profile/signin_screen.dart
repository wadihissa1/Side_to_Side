import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/palette.dart';
import '../constants.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Future<void> _saveSession(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);
    print('Session saved: token=$token, userId=$userId'); // Debug log
  }



  Future<void> _signIn(BuildContext context, String email, String password) async {
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.buttonTap);

    try {
      final String timezone = DateTime.now().timeZoneName;
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'timezone': timezone,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final String message =
              responseData['message']?.toString() ?? 'Login successful';
          final String token = responseData['token']?.toString() ?? '';
          final int userId = responseData['user']['id'] as int;

          // Save session
          await _saveSession(token, userId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );

          // Navigate to MainMenuScreen
          context.go('/');
        } else {
          final String message =
              responseData['message']?.toString() ?? 'Login failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else if (response.statusCode == 403) {
        final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;
        final String message =
            responseData['message']?.toString() ?? 'Email not verified.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials.')),
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
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.buttonTap);

    final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

    try {
      await _googleSignIn.signOut(); // Force account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final String? token = googleAuth.accessToken;

        // Call API with Google token
        final response = await http.post(
          Uri.parse(googleLoginEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;
          if (responseData['success'] == true) {
            final String message =
                responseData['message']?.toString() ?? 'Google Sign-In successful!';
            final int userId = responseData['user']['id'] as int;
            final String appToken = responseData['token']?.toString() ?? '';

            // Save session
            await _saveSession(appToken, userId);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );

            // Navigate to MainMenuScreen
            context.go('/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Google Sign-In failed. ${responseData['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google Sign-In failed with status ${response.statusCode}')),
          );
        }
      }
    } catch (error) {
      print('Google Sign-In error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In error: $error')),
      );
    }
  }

  Future<void> _forgotPassword(BuildContext context, String email) async {
    try {
      final response = await http.post(
        Uri.parse(forgotPasswordEndpoint), // Reset Password API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
        jsonDecode(response.body) as Map<String, dynamic>;
        final String message =
            responseData['message']?.toString() ?? 'Password reset link sent!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset link. Please try again.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter your email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final email = emailController.text.trim();
                _forgotPassword(context, email);
                Navigator.pop(context);
              },
              child: const Text('Send Link'),
            ),
          ],
        );
      },
    );
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
      body: SingleChildScrollView(
        child: Padding(
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _showForgotPasswordDialog(context);
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.signInButton.color,
                  foregroundColor: palette.signInButtonText.color,
                ),
                onPressed: () {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  _signIn(context, email, password);
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                onPressed: () {
                  _signInWithGoogle(context);
                },
                label: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
