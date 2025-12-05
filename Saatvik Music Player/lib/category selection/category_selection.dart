import 'package:flutter/material.dart';

class SongCategory {
  final String id;
  final String label;
  final IconData icon;

  const SongCategory({required this.id, required this.label, required this.icon});
}

const List<SongCategory> categories = [
  SongCategory(id: 'all', label: 'All Songs', icon: Icons.playlist_play),
  SongCategory(id: 'uploads', label: 'Latest Uploads', icon: Icons.new_releases),
  SongCategory(id: 'artists', label: 'Various Artists', icon: Icons.people),
  SongCategory(id: 'bhajans', label: 'Bhajans / Devotional', icon: Icons.self_improvement),
  SongCategory(id: 'party', label: 'Party / Dance', icon: Icons.celebration),
  SongCategory(id: 'gym', label: 'Gym / Workout', icon: Icons.fitness_center),
  SongCategory(id: 'marathons', label: 'Marathon / Running', icon: Icons.directions_run),
  SongCategory(id: 'cooking', label: 'Cooking / Chill', icon: Icons.soup_kitchen),
  SongCategory(id: 'old songs', label: 'Old Songs', icon: Icons.calendar_month),
  SongCategory(id: 'hollywood', label: 'Hollywood', icon: Icons.movie_filter),
  // Add more categories here as needed
];