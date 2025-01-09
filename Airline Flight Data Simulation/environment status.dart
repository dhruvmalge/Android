class EnvironmentalData {
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double precipitation;
  final double visibility;
  final double cloudCover;
  final double dewPoint;

  EnvironmentalData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.precipitation,
    required this.visibility,
    required this.cloudCover,
    required this.dewPoint,
  });

  factory EnvironmentalData.fromJson(Map<String, dynamic> json) {
    return EnvironmentalData(
      temperature: json['temperature'],
      humidity: json['humidity'],
      pressure: json['pressure'],
      windSpeed: json['wind_speed'],
      precipitation: json['precipitation'],
      visibility: json['visibility'],
      cloudCover: json['cloud_cover'],
      dewPoint: json['dew_point'],
    );
  }
}
