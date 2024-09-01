const List<Song> songs = [
  Song('piano_1.mp3', 'Bit Forrest', artist: 'bertz'),
  Song('piano_1.mp3', 'Free Run', artist: 'TAD'),
  Song('piano_1.mp3', 'Tropical Fantasy', artist: 'Spring Spring'),
];

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
