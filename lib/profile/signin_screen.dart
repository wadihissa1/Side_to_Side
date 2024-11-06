import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../style/palette.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: palette.backgroundSignIn.color, // Sign-in background color
      appBar: AppBar(
        title: Text(
          'Sign In',
          style: TextStyle(color: palette.signInText.color), // Sign-in text color
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
            // Email Field
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

            // Password Field
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

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.signInButton.color, // Button color
                foregroundColor: palette.signInButtonText.color, // Button text color
              ),
              onPressed: () {
                // Implement sign-in logic here
                final email = emailController.text;
                final password = passwordController.text;
                // Call sign-in function with email and password
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
