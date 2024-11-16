const List<Song> songs = [
  Song('bit_forrest.mp3', 'Bit Forrest', artist: 'bertz'),
  Song('bit_forrest.mp3', 'Free Run', artist: 'TAD'),
  Song('bit_forrest.mp3', 'Tropical Fantasy', artist: 'Spring Spring'),
];

class Song {
  final String filename;

  final String name;

  final String? artist;

  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}
