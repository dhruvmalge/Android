enum AudioQuality {
  dataSaver, // Corresponds to 128KBPS
  highQuality, // Corresponds to 320KBPS
}

extension AudioQualityExtension on AudioQuality {
  String get rate => switch (this) {
    AudioQuality.dataSaver => '128',
    AudioQuality.highQuality => '320',
  };
  String get label => switch (this) {
    AudioQuality.dataSaver => 'Data Saver (128kbps)',
    AudioQuality.highQuality => 'HD (320kbps)',
  };
}