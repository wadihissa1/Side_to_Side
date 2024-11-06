import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../style/palette.dart';

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        backgroundColor: palette.backgroundSkins.color, // Background color
        appBar: AppBar(
          title: Text(
            'Skins',
            style: TextStyle(color: palette.skinsText.color), // Text color
          ),
          backgroundColor: palette.backgroundSkins.color,
          iconTheme: IconThemeData(color: palette.skinsText.color),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Player Skins'),
              Tab(text: 'Background Skins'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PlayerSkinsTab(),
            BackgroundSkinsTab(),
          ],
        ),
      ),
    );
  }
}

class PlayerSkinsTab extends StatelessWidget {
  const PlayerSkinsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return ListView.builder(
      itemCount: 2, // Number of player skins available
      itemBuilder: (context, index) {
        final isUnlocked = index % 2 == 0;

        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(
              'assets/images/player_skin_${index + 1}.png', // Replace with actual asset path
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            'Player Skin ${index + 1}',
            style: TextStyle(color: palette.skinsText.color),
          ),
          trailing: Text(
            isUnlocked ? 'Unlocked' : 'Locked',
            style: TextStyle(
              color: isUnlocked ? palette.unlockedText.color : palette.lockedText.color,
            ),
          ),
        );
      },
    );
  }
}

class BackgroundSkinsTab extends StatelessWidget {
  const BackgroundSkinsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return ListView.builder(
      itemCount: 2, // Number of background skins available
      itemBuilder: (context, index) {
        final isUnlocked = index % 2 == 1;

        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset(
              'assets/images/background_skin_${index + 1}.png', // Replace with actual asset path
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            'Background Skin ${index + 1}',
            style: TextStyle(color: palette.skinsText.color),
          ),
          trailing: Text(
            isUnlocked ? 'Unlocked' : 'Locked',
            style: TextStyle(
              color: isUnlocked ? palette.unlockedText.color : palette.lockedText.color,
            ),
          ),
        );
      },
    );
  }
}
