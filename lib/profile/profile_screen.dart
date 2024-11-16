import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../style/palette.dart';
import '../audio/audio_controller.dart';
import '../audio/sounds.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;
  final String token;

  const ProfileScreen({super.key, required this.userId, required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isLoggedIn = false;
  String token = '';
  int? userId;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    userId = prefs.getInt('userId');

    if (token.isNotEmpty && userId != null) {
      setState(() {
        isLoggedIn = true;
      });
      await fetchUserData();
    } else {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$userprofileEndpoint/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body) as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch user data')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.buttonTap);

    try {
      final response = await http.post(
        Uri.parse('$logoutEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await clearSession();
        setState(() {
          userData = null;
          isLoggedIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log out')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final audioController = context.read<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundProfile.color,
      appBar: AppBar(
        title: Text(
          isLoggedIn ? 'Profile' : 'Guest Mode',
          style: TextStyle(color: palette.profileText.color),
        ),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => logout(context),
            ),
        ],
        backgroundColor: palette.backgroundProfile.color,
        iconTheme: IconThemeData(color: palette.profileText.color),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isLoggedIn && userData != null) ...[
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData!['profile_image'] != null &&
                      userData!['profile_image']!.toString().isNotEmpty
                      ? NetworkImage(
                      userData!['profile_image']!.toString())
                      : null,
                  child: userData!['profile_image'] == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  '${userData!['username']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: palette.profileText.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Score: ${userData!['score']}',
                  style: TextStyle(
                    fontSize: 18,
                    color: palette.profileText.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Retry Times: ${userData!['retry_times']}',
                  style: TextStyle(
                    fontSize: 18,
                    color: palette.profileText.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Coins: ${userData!['coin']}',
                  style: TextStyle(
                    fontSize: 18,
                    color: palette.profileText.color,
                  ),
                  textAlign: TextAlign.center,
                ),

              ] else ...[
                const Icon(Icons.person, size: 100),
                const SizedBox(height: 16),
                const Text(
                  'Welcome, Guest!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.profileButton.color,
                    foregroundColor: palette.profileButtonText.color,
                  ),
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonTap);
                    context.go('/profile/signin');
                  },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.profileButton.color,
                    foregroundColor: palette.profileButtonText.color,
                  ),
                  onPressed: () {
                    audioController.playSfx(SfxType.buttonTap);
                    context.go('/profile/signup');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.profileButton.color,
                  foregroundColor: palette.profileButtonText.color,
                ),
                onPressed: () {
                  audioController.playSfx(SfxType.buttonTap);
                  context.go('/profile/skins');
                },
                child: const Text('Skins'),
              ),
              if (isLoggedIn)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.profileButton.color,
                    foregroundColor: palette.profileButtonText.color,
                  ),
                  onPressed: () => logout(context),
                  child: const Text('Logout'),
                )
            ],
          ),
        ),
      ),
    );
  }
}
