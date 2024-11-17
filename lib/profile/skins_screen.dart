import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../constants.dart';
import '../style/palette.dart';
import '../providers/game_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: palette.backgroundSkins.color,
        appBar: AppBar(
          title: Text(
            'Skins',
            style: TextStyle(color: palette.skinsText.color),
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


class PlayerSkinsTab extends StatefulWidget {
  const PlayerSkinsTab({super.key});

  @override
  _PlayerSkinsTabState createState() => _PlayerSkinsTabState();
}

class _PlayerSkinsTabState extends State<PlayerSkinsTab> {
  late Future<List<Map<String, dynamic>>> _skinsFuture;

  @override
  void initState() {
    super.initState();
    _skinsFuture = fetchSkins();
  }

  Future<void> _refreshSkins() async {
    setState(() {
      _skinsFuture = fetchSkins();
    });
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('Retrieved user_id: $userId'); // Debug output
    if (userId == null) {
      throw Exception('User ID is not found. Please log in again.');
    }
    return userId;
  }

  Future<List<Map<String, dynamic>>> fetchSkins() async {
    final userId = await getUserId();
    final response = await http.get(
      Uri.parse('$getSkinsAndBackgroundsEndpoint?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['skins'] as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } catch (e) {
        throw Exception('Failed to parse skins data: $e');
      }
    } else {
      throw Exception('Failed to fetch skins. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return RefreshIndicator(
      onRefresh: _refreshSkins,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _skinsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No skins available.'));
          }

          final skins = snapshot.data!;




          return ListView.builder(
            itemCount: skins.length,
            itemBuilder: (context, index) {
              final skin = skins[index];
              final String name = skin['name']?.toString() ?? 'Unknown';
              final String image = skin['image']?.toString() ?? '';
              final int cost = skin['cost'] as int;
              final bool isUnlocked = skin['isUnlocked'] as bool;
              final bool isSelected = skin['isSelected'] as bool;

              final String baseUrl = 'http://192.168.18.37:8000'; // Replace with your server's base URL
              final String imageUrl = image.isNotEmpty ? '$baseUrl/storage/$image' : '';

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                )
                    : const SizedBox(),
                title: Text(name, style: TextStyle(color: palette.skinsText.color)),
                subtitle: Text('Cost: $cost'),
                trailing: isUnlocked
                    ? ElevatedButton(
                  onPressed: isSelected
                      ? null
                      : () {
                    selectItem(context, 'skin', skin['id'] as int);
                  },
                  child: Text(isSelected ? 'Selected' : 'Select'),
                )
                    : ElevatedButton(
                  onPressed: () {
                    purchaseItem(context, 'skin', skin['id'] as int);
                  },
                  child: const Text('Buy'),
                ),
              );

            },
          );
        },
      ),
    );
  }

  Future<void> selectItem(BuildContext context, String itemType, int itemId) async {
    final userId = await getUserId();
    final response = await http.post(
      Uri.parse(selectItemEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_type': itemType, 'item_id': itemId, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      Provider.of<GameSettings>(context, listen: false).setSelectedSkin(itemId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skin selected!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to select skin.')));
    }
  }

  Future<void> purchaseItem(BuildContext context, String itemType, int itemId) async {
    final userId = await getUserId();
    final response = await http.post(
      Uri.parse(purchaseItemEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_type': itemType, 'item_id': itemId, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item purchased!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to purchase item.')));
    }
  }
}

class BackgroundSkinsTab extends StatefulWidget {
  const BackgroundSkinsTab({super.key});

  @override
  _BackgroundSkinsTabState createState() => _BackgroundSkinsTabState();
}

class _BackgroundSkinsTabState extends State<BackgroundSkinsTab> {
  late Future<List<Map<String, dynamic>>> _backgroundsFuture;

  @override
  void initState() {
    super.initState();
    _backgroundsFuture = fetchBackgrounds();
  }

  Future<void> _refreshBackgrounds() async {
    setState(() {
      _backgroundsFuture = fetchBackgrounds();
    });
  }

  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      throw Exception('User ID is not found. Please log in again.');
    }
    return userId;
  }

  Future<List<Map<String, dynamic>>> fetchBackgrounds() async {
    final userId = await getUserId();
    final response = await http.get(
      Uri.parse('$getSkinsAndBackgroundsEndpoint?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['backgrounds'] as List<dynamic>)
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } catch (e) {
        throw Exception('Failed to parse backgrounds data: $e');
      }
    } else {
      throw Exception('Failed to fetch backgrounds. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return RefreshIndicator(
      onRefresh: _refreshBackgrounds,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _backgroundsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No backgrounds available.'));
          }

          final backgrounds = snapshot.data!;

          return ListView.builder(
            itemCount: backgrounds.length,
            itemBuilder: (context, index) {
              final background = backgrounds[index];
              final String name = background['name']?.toString() ?? 'Unknown';
              final String image = background['image']?.toString() ?? '';
              final int cost = background['cost'] as int;
              final bool isUnlocked = background['isUnlocked'] as bool;
              final bool isSelected = background['isSelected'] as bool;

              final String baseUrl = 'http://192.168.18.37:8000'; // Replace with your server's base URL
              final String imageUrl = image.isNotEmpty ? '$baseUrl/storage/$image' : '';

              return ListTile(
                leading: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                )
                    : const SizedBox(),
                title: Text(name, style: TextStyle(color: palette.skinsText.color)),
                subtitle: Text('Cost: $cost'),
                trailing: isUnlocked
                    ? ElevatedButton(
                  onPressed: isSelected
                      ? null
                      : () {
                    selectItem(context, 'background', background['id'] as int);
                  },
                  child: Text(isSelected ? 'Selected' : 'Select'),
                )
                    : ElevatedButton(
                  onPressed: () {
                    purchaseItem(context, 'background', background['id'] as int);
                  },
                  child: const Text('Buy'),
                ),
              );

            },
          );
        },
      ),
    );
  }

  Future<void> selectItem(BuildContext context, String itemType, int itemId) async {
    final userId = await getUserId();
    final response = await http.post(
      Uri.parse(selectItemEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_type': itemType, 'item_id': itemId, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      Provider.of<GameSettings>(context, listen: false).setSelectedBackground(itemId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Background selected!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to select background.')));
    }
  }

  Future<void> purchaseItem(BuildContext context, String itemType, int itemId) async {
    final userId = await getUserId();
    final response = await http.post(
      Uri.parse(purchaseItemEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'item_type': itemType, 'item_id': itemId, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item purchased!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to purchase item.')));
    }
  }
}