import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../style/palette.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: palette.backgroundSignUp.color, // Background color
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(color: palette.signUpText.color), // AppBar text color
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
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.signUpButton.color, // Button background color
                foregroundColor: palette.signUpButtonText.color, // Button text color
              ),
              onPressed: () {
                // Implement sign-up logic here
                final email = emailController.text;
                final password = passwordController.text;
                // Call sign-up function with email and password
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
