import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../style/palette.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the palette from the context
    final palette = context.watch<Palette>();

    // Placeholder values
    final String userName = "Wadih"; // Replace with actual username data
    final int bestScore = 157; // Replace with actual best score data

    return Scaffold(
      backgroundColor: palette.backgroundProfile.color, // Profile background color
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: palette.profileText.color), // Profile text color
        ),
        backgroundColor: palette.backgroundProfile.color,
        iconTheme: IconThemeData(color: palette.profileText.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Name
            Text(
              'Name: $userName',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: palette.profileText.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Display Best Score
            Text(
              'Best Score: $bestScore',
              style: TextStyle(
                fontSize: 20,
                color: palette.profileText.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Sign In Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.profileButton.color, // Updated to backgroundColor
                foregroundColor: palette.profileButtonText.color, // Updated to foregroundColor
              ),
              onPressed: () => context.push('/profile/signin'),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            
            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.profileButton.color, // Updated to backgroundColor
                foregroundColor: palette.profileButtonText.color, // Updated to foregroundColor
              ),
              onPressed: () => context.push('/profile/signup'),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),

            // Skins Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.profileButton.color, // Updated to backgroundColor
                foregroundColor: palette.profileButtonText.color, // Updated to foregroundColor
              ),
              onPressed: () => context.push('/profile/skins'),
              child: const Text('Skins'),
            ),
          ],
        ),
      ),
    );
  }
}
