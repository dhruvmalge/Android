enum AudioQuality {
  dataSaver,
  highQuality,
  hdQuality,
}

extension AudioQualityExtension on AudioQuality {
  String get rate => switch (this) {
    AudioQuality.dataSaver => '64',
    AudioQuality.highQuality => '128',
    AudioQuality.hdQuality => '320'
  };
  String get label => switch (this) {
    AudioQuality.dataSaver => 'Data Saver (64 kbps)',
    AudioQuality.highQuality => 'HQ (128 kbps)',
    AudioQuality.hdQuality => 'HD (320 kbps)'
  };
}