import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';

import '../level_selection/levels.dart';
import '../style/palette.dart';

/// This dialog is shown when the game ends (e.g., after collision with an obstacle).
class GameWinDialog extends StatelessWidget {
  const GameWinDialog({
    super.key,
    required this.level,
    required this.highScore,
    required this.coinsCollected,
  });

  /// The properties of the current level.
  final GameLevel level;

  /// The high score achieved during the game.
  final int highScore;

  /// The total number of coins collected during the game.
  final int coinsCollected;

  /// Sends high score, coins collected, and retry times to the API.
  Future<void> sendScoreAndCoinsToDatabase(
      int highScore, int coinsCollected) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId'); // Retrieve user_id from SharedPreferences

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences.');
      }

      final url = Uri.parse(sendscoreandcoinEndpoint);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'score': highScore,
          'coin': coinsCollected,
          'retry_times': 1, // Increment retry times by 1 for each game play
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update score and coins: ${response.body}');
      }

      print('Score, coins, and retry times updated successfully.');
    } catch (e) {
      print('Error updating score, coins, and retry times: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();

    return Center(
      child: NesContainer(
        width: 420,
        height: 300,
        backgroundColor: palette.backgroundPlaySession.color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Game Over!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Level ${level.number} completed.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'High Score: $highScore',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Coins Collected: $coinsCollected',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            NesButton(
              onPressed: () async {
                // Call the function to send data to the API
                await sendScoreAndCoinsToDatabase(highScore, coinsCollected);

                // Navigate back to level selection
                context.go('/play');
              },
              type: NesButtonType.normal,
              child: const Text('Level selection'),
            ),
          ],
        ),
      ),
    );
  }
}
