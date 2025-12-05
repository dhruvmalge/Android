import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class LocalSong {
  final String path;
  final String title;
  final String artist;

  LocalSong({required this.path, required this.title, this.artist = 'Unknown'});

  @override
  String toString() => 'Song: $title (Path: $path)';
}


const List<String> _musicExtensions = ['.mp3', '.wav', '.ogg', '.flac'];

Future<List<LocalSong>> loadSongsFromLocalStorage() async {
  List<LocalSong> localSongs = [];

  var status = await Permission.storage.request();
  if (!status.isGranted) {
    print('Storage permission denied. Cannot load local music.');
    return [];
  }

  List<Directory> directoriesToScan = [];
  try {


    final externalDirs = await getExternalStorageDirectories();
    if (externalDirs != null) {
      directoriesToScan.addAll(externalDirs);
    }

    final rootDir = await getExternalStorageDirectory();
    if (rootDir != null) {
      directoriesToScan.add(rootDir);
    }


  } catch (e) {
    print('Error accessing external storage paths: $e');
    return [];
  }

  for (var directory in directoriesToScan) {
    if (directory.path.contains('Android/')) continue;
    final Directory musicDir = Directory('${directory.path}');

    if (await musicDir.exists()) {
      print('Scanning directory: ${musicDir.path}');
      try {
        await for (var entity in musicDir.list(recursive: true)) {
          if (entity is File) {
            String extension = entity.path.toLowerCase().substring(
              entity.path.lastIndexOf('.'),
            );
            if (_musicExtensions.contains(extension)) {
              String fileName = entity.path.split('/').last;
              String title = fileName.replaceAll(extension, '');

              localSongs.add(LocalSong(path: entity.path, title: title));
            }
          }
        }
      } catch (e) {
        print('Error reading files in ${musicDir.path}: $e');
      }
    }
  }
  print('Found ${localSongs.length} local songs.');
  return localSongs;
}